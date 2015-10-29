#' Impute missing RIT scores
#'
#' @param mapvizieR_obj a mapvizieR object
#' @param studentids a vector of studentids to run
#' @param measurementscale desired subject
#' @param impute_method one of: c('simple_average')
#' @param interpolate_only should the scaffold return ALL seasons, ever, or only
#' ones in between the student's first/last test?
#'
#' @return a cdf object, with imputed rows
#' @export

impute_rit <- function(
  mapvizieR_obj, 
  studentids, 
  measurementscale, 
  impute_method = 'simple_average',
  interpolate_only = TRUE
  ) {
 
  if (!impute_method %in% c('simple_average')) {
    stop(
      paste(impute_method, 'is not a valid imputation method.',
        'check the documentation.')
    )      
  }
  
  #unpack the mapvizieR object and limit to desired students
  this_cdf <- mv_limit_cdf(mapvizieR_obj, studentids, measurementscale) %>%
    dplyr::tbl_df()

  if (impute_method == 'simple_average') {
    out <- impute_rit_simple_average(this_cdf, interpolate_only)
  }
   
  out
}


#' Build out the base scaffold of possible terms for every student.
#'
#' @param cdf a processed cdf.  assumes that there are no same student/subj/season 
#' dupes.
#' @param interpolate_only should the scaffold return ALL seasons, ever, or only
#' ones in between the student's first/last test?
#'
#' @return a cdf, with rows for imputation
#' @export

imputation_scaffold <- function(cdf, interpolate_only = TRUE) {

  #cartesian product of students, terms and measurementscales
  unq_terms <- cdf$grade_level_season %>% unique()
  unq_stu <- cdf$studentid %>% unique()
  unq_subj <- cdf$measurementscale %>% unique()
  
  scaffold <- expand.grid(unq_stu, unq_terms, unq_subj, stringsAsFactors = FALSE)
  names(scaffold) <- c('studentid', 'grade_level_season', 'measurementscale')
  
  #min and max grade_level_season, by student
  stu_extent <- cdf %>%
    dplyr::group_by(studentid) %>%
    dplyr::summarize(
      min_grade_level_season = min(grade_level_season, na.rm = TRUE),
      max_grade_level_season = max(grade_level_season, na.rm = TRUE)
    )
  
  if(interpolate_only) {
    #grade level season bounds
    scaffold <- scaffold %>%
      dplyr::left_join(
        stu_extent, by = c('studentid')
      ) %>%
      dplyr::filter(
        grade_level_season >= min_grade_level_season &
        grade_level_season <= max_grade_level_season
      )
  }
  
  #tag the real cdf with 'observed' before join, to distinguish
  #between imputed and observed rows
  cdf$row_type <- 'observed'
  
  #join back
  scaffold <- scaffold %>%
    dplyr::left_join(
      cdf, by = c('studentid', 'grade_level_season', 'measurementscale')
    ) %>%
    dplyr::mutate(
      row_type = ifelse(is.na(row_type), 'imputed', 'observed')
    ) %>%
    dplyr::arrange(
      studentid, measurementscale, grade_level_season
    ) %>%
    dplyr::tbl_df()
  
  #test if all rows for a stu/subject paring are NA.  drop if so.
  stu_subj <- scaffold %>%
    dplyr::group_by(studentid, measurementscale) %>%
    dplyr::summarize(
      num_valid = sum(
        ifelse(testritscore %>% is.na(), 0, 1)
      )
    ) %>%
    dplyr::filter(num_valid > 0)
  
  scaffold <- scaffold %>%
    dplyr::inner_join(stu_subj, by = c('studentid', 'measurementscale'))
    
  return(scaffold)  
}


#' Utility function to identify groups/runs when imputing
#'
#' @param logicals a vector of logicals (indicating if the rit score is known or NA)
#'
#' @return a vector of integers, representing the sequential group number

imputation_grouper <- function(logicals) {
  runs <- rle(logicals)
  out <- rep(1:length(runs$values), runs$lengths)
  
  return(out)
}


#' Use simple averaging to impute missing rows
#'
#' @param cdf a CDF data frae
#' @param interpolate_only should the scaffold return ALL seasons, ever, or only
#' ones in between the student's first/last test?
#'
#' @return a CDF data frame with imputed rows
#' @export

impute_rit_simple_average <- function(cdf, interpolate_only = TRUE) {
  
  if (!interpolate_only == TRUE) {
    stop('imputation by simple average currently only supports interpolation')
  }
  
  #make scaffold
  scaffold <- imputation_scaffold(cdf, interpolate_only)
  scaffold$row_number <- rownames(scaffold) %>% as.numeric()
  
  #add lead and lag (for interpolation) and na flag
  scaffold <- scaffold %>%
    dplyr::arrange(studentid, measurementscale, grade_level_season) %>%
    dplyr::group_by(studentid, measurementscale) %>%
    dplyr::mutate(
      lag = lag(row_number, 1),
      lead = lead(row_number, 1),
      na_flag = ifelse(is.na(testritscore), TRUE, FALSE)
    )
  
  #determine NA groups per student
  scaffold <- scaffold %>%
    dplyr::group_by(studentid, measurementscale) %>%
    dplyr::mutate(
      group = imputation_grouper(na_flag)
    )
  
  #data frame with NAs, and the leading/lagging values
  na_extents <- scaffold %>%
    dplyr::filter(na_flag) %>%
    dplyr::group_by(studentid, measurementscale, group) %>%
    dplyr::summarize(
      min_extent = min(lag, na.rm = TRUE),
      max_extent = max(lead, na.rm = TRUE),
      min_grade = min(grade_level_season, na.rm = TRUE),
      max_grade = max(grade_level_season, na.rm = TRUE),
      count = n()
    )
  
  #add min and max extent RIT
  #min
  na_extents <- na_extents %>%
    dplyr::left_join(
      scaffold %>% dplyr::ungroup() %>% 
        dplyr::select(row_number, testritscore) %>% 
        dplyr::rename(min_extent_rit = testritscore),
      by = c('min_extent' = 'row_number')
    )
  #max
  na_extents <- na_extents %>%
    dplyr::left_join(
      scaffold %>% dplyr::ungroup() %>% 
        dplyr::select(row_number, testritscore) %>% 
        dplyr::rename(max_extent_rit = testritscore),
      by = c('max_extent' = 'row_number')
    )
  
  na_extents <- na_extents %>%
    dplyr::mutate(
      interpolate_flag = !is.na(min_extent) & !is.na(max_extent) &
        !is.na(min_extent_rit) & !is.na(max_extent_rit)
    )
    
  #TODO: if we want to extrapolate, handle that here
  #for rows where interpolate_flag == FALSE
  if (interpolate_only) {
    na_extents <- na_extents %>%
      dplyr::filter(interpolate_flag)
  }
  
  #per term change
  na_extents <- na_extents %>%
    dplyr::mutate(
      increment = (max_extent_rit - min_extent_rit) / (count + 1)
    )
  
  simple_average_helper <- function(
    studentid_in, measurementscale_in, group_in, testritscore_in, na_flag_in
  ) {
    out <- ifelse(is.na(testritscore_in), NA_real_, testritscore_in)
    
    if (any(na_flag_in)) {
      #find the matching na_extent
      this_extent <- na_extents %>%
        dplyr::filter(
          studentid == studentid_in %>% unique() &
            measurementscale == measurementscale_in %>% unique() &
            group == group_in %>% unique()
        )
      
      #if it matches
      if (nrow(this_extent) > 0) {
        out <- this_extent$min_extent_rit + 
          (rep(this_extent$increment, this_extent$count) * c(1:this_extent$count))
        out <- as.integer(out)
      } else {
        out <- ifelse(is.na(testritscore_in), NA_integer_, testritscore_in)
      }
    }
    
    return(out)
  }
  
  #process using new function
  scaffold <- scaffold %>%
    dplyr::group_by(studentid, measurementscale, group) %>%
    dplyr::mutate(
      testritscore = simple_average_helper(studentid, measurementscale, group, testritscore, na_flag)
    ) %>%
    dplyr::ungroup()
  
  #only original names
  name_mask <- names(scaffold) %in% c(names(cdf), 'row_type')
  out <- scaffold[, name_mask]

  return(out)
}