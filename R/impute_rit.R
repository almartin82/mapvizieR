impute_rit <- function(
  mapvizieR_object, 
  studentids, 
  measurementscale, 
  impute_method = 'simple_average'
  ) {
 
  if (!impute_method %in% c('simple_average')) {
    stop(
      paste(impute_method, 'is not a valid imputation method.',
        'check the documentation.')
    )      
  }
  
  #unpack the mapvizieR object and limit to desired students
  this_cdf <- mv_limit_cdf(mapvizieR_object, studentids, measurementscale) %>%
    dplyr::tbl_df()

  if (impute_method == 'simple_average') {
    out <- impute_rit_simple_average(this_cdf)
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
#' @return 
#' @export

candidate_scaffold <- function(cdf, interpolate_only = TRUE) {

  #cartesian product of students, terms and measurementscales
  unq_terms <- cdf$grade_level_season %>% unique()
  unq_stu <- cdf$studentid %>% unique()
  unq_subj <- cdf$measurementscale %>% unique()
  
  scaffold <- expand.grid(unq_stu, unq_terms, unq_subj)
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
  
  #join back
  scaffold <- scaffold %>%
    dplyr::left_join(
      cdf, by = c('studentid', 'grade_level_season', 'measurementscale')
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


run_length_grouper <- function(logicals) {
  runs <- rle(logicals)
  out <- rep(1:length(runs$values), runs$lengths)
  
  return(out)
}






foo <- function() {
  cdf <- processed_cdf
  cdf[cdf$testid == 122220176, ]$testritscore <- NA
}

impute_rit_simple_average <- function(cdf, interpolate_only = TRUE) {
  
  #make scaffold
  scaffold <- candidate_scaffold(cdf, interpolate_only)
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
      group = run_length_grouper(logical)
    )
  
  #data frame of NAs
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
  
  scaffold %>%
    dplyr::filter(studentid == 'SF06000348' & measurementscale == 'Mathematics') %>%
    #dplyr::filter(is.na(testritscore)) %>%
    dplyr::select(
      studentid, grade_level_season, measurementscale, testritscore,
      row_number, lag, lead, na_flag, group
    ) %>% as.data.frame()


  
}