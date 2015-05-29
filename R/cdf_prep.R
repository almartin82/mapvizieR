utils::globalVariables(c("%>%", "mutate"))

#' @title prep_cdf_long
#'
#' @description
#' \code{prep_cdf_long} a wrapper around several cdf prep functions
#'
#' @param cdf_long a map assessmentresults.csv file.  can be one term, or many terms
#' together in one file.
#' 
#' @return a prepped cdf file
#' 
#' @export

prep_cdf_long <- function(cdf_long) {
  
  cdf_long <- cdf_long %>% 
    #names
    lower_df_names() %>%
    #fallwinterspring, academic_year
    extract_academic_year()
    
  cdf_long$measurementscale <- clean_measurementscale(cdf_long$measurementscale)
  cdf_long$teststartdate <- munge_startdate(cdf_long$teststartdate)
  cdf_long$growthmeasureyn <- as.logical(cdf_long$growthmeasureyn)
  
  assertthat::assert_that(check_cdf_long(cdf_long)$boolean)
  
  return(cdf_long)
}


#' @title process_cdf_long
#'
#' @description
#' \code{process_cdf_long} the second step in cdf processing
#'
#' @param prepped_cdf output of prep_cdf_long
#' 
#' @return a processed cdf file
#' 
#' @export

process_cdf_long <- function(prepped_cdf) {
  
  prepped_cdf %>% 
    dedupe_cdf(method="NWEA") %>%
    grade_level_seasonify() %>%
    grade_season_labelify() %>%
    grade_season_factors() %>%
    make_npr_consistent() %>%
    dplyr::mutate(
      testquartile = kipp_quartile(consistent_percentile),
      #testids for client server are NULL.  we'll force a unique identifier here.
      testid = ifelse(
        #test
        is.na(testid),
        #if TRUE
        paste(studentid, measurementscale, teststartdate, teststarttime, sep='_'), 
        #if FALSE
        testid)
    )
}


#' @title dedupe_cdf
#'
#' @description
#' \code{dedupe_cdf} makes sure that the cdf only contains one row student/subject/term 
#'
#' @param prepped_cdf conforming prepped cdf file.
#' @param method can choose between c('NWEA', 'high RIT', 'most recent').  
#' Default is NWEA method.
#' 
#' @return a data frame with one row per kid
#' 
#' @export

dedupe_cdf <- function(prepped_cdf, method="NWEA") {
  #verify inputs
  assertthat::assert_that(
    is.data.frame(prepped_cdf),
    method %in% c("NWEA", "high RIT", "most recent"),
    check_cdf_long(prepped_cdf)$boolean
  )

  #reminder: if you want the highest value for an element to rank 1, 
    #throw a negative sign in front of the variable
    #if you want the lowest to rank 1, leave as is.
  rank_methods <- list(
    "NWEA" = "-growthmeasureyn, teststandarderror",
    "high RIT" = "-testritscore",
    "most recent" = "rev(teststartdate)"
  )
  
  #pull the method off the list
  use_method <- rank_methods[[method]]
  do_call_rank_with_method <- paste0("do.call(rank, list(", use_method, "))")  
  
  #dedupe using dplyr mutate
  dupe_tagged <- prepped_cdf %>%
    dplyr::group_by(studentid, measurementscale, map_year_academic, fallwinterspring) %>%
    #using mutate_ because we want to hand our function to mutate as a string. 
    dplyr::mutate_(
      rn=do_call_rank_with_method
    )  
  deduped <- dupe_tagged[dupe_tagged$rn==1, ]
  
  return(deduped)
}



#' @title grade_level_seasonify
#'
#' @description
#' \code{grade_level_seasonify} turns grade level into a simplified continuous scale, 
#' using consistent offsets for MAP 'seasons'  
#'
#' @param cdf a cdf that has 'grade' and 'fallwinterspring' columns (eg product of )
#' \code{grade_levelify()}
#' 
#' @return a data frame with a 'grade_level_season' column

grade_level_seasonify <- function(cdf) {
  
  #inputs consistency check 
  cdf %>%
    ensurer::ensures_that(
      c('grade', 'fallwinterspring') %in% names() ~ "'grade' 
        and 'fallwinterspring' must be in in your cdf to 
        grade_seasonify"
    )
  
  season_offsets <- data.frame(
    season=c('Fall', 'Winter', 'Spring', 'Summer')
   ,offset=c(-0.8, -0.5, 0, 0.1)
  )
  
  #get the offset
  munge <- dplyr::left_join(
    x = cdf,
    y = season_offsets,
    by = c('fallwinterspring' = 'season')
  )
  
  munge %>%
    dplyr::mutate(
      grade_level_season = grade + offset
    ) %>%
    dplyr::select(-offset) %>%
    as.data.frame()
}



#' @title grade_season_labelify
#'
#' @description
#' \code{grade_season_labelify} returns an abbreviated label ('5S') that is useful when
#' labelling charts  
#'
#' @param x a cdf that has 'grade_level_season' (eg product of grade_level_seasonify)
#' \code{grade_levelify()}
#' 
#' @return a data frame with a grade_season_labels

grade_season_labelify <- function(x) {
  
  assertthat::assert_that('grade_level_season' %in% names(x))
  x$grade_season_label <- fall_spring_me(x$grade_level_season)
    
  return(as.data.frame(x))
}



#' @title grade_season_factors
#' 
#' @description helper function that 1) converts grade_season_label to factor and
#' 2) orders the labels based on grade_level_season
#' 
#' @param x a cdf that has grade_level_season and grade_season_label

grade_season_factors <- function(x) {
  
  x$grade_season_label <- factor(
    x$grade_season_label,
    levels = unique(x[order(x$grade_level_season),]$grade_season_label),
    ordered = TRUE  
  )
  
  return(x)
}



#' @title make_npr_consistent
#' 
#' @description join a cdf to a norms study and get the empirical 
#' percentiles.  protects against longitudinal findings being 
#' clouded by changes in the norms.
#' 
#' @param cdf a mostly-processed cdf object (this is the last step)
#' in process_cdf
#' @param norm_study name of a norm study.  default is 2011.  look in norm_data.R
#' for documentation of available norm studies.

make_npr_consistent <- function(
  cdf,
  norm_study = 'student_status_norms_2011'
) {
  #read norm df from text
  norm_df <- eval(as.name(norm_study))

  #make sure that cdf has required fields
  ensure_fields(
    c('measurementscale', 'fallwinterspring', 'grade', 'testritscore'),
    cdf
  )
      
  names(norm_df)[names(norm_df)=='percentile'] <- 'consistent_percentile'
  norm_df$percentile_source <- norm_study

  dplyr::left_join(
    x = cdf,
    y = norm_df,
    by = c(
      "measurementscale" = "measurementscale",
      "fallwinterspring" = "fallwinterspring",
      "grade" = "grade",
      "testritscore" = "RIT"
    )
  )
}


#' @title psuedo_testids
#' 
#' @description if testids are NA, generate a unique identifier
#' 
#' @param x a cdf of testids

psuedo_testids <- function(x) {
  
}