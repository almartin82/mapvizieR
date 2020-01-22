#' @title summary method for \code{mapvizieR} class
#'
#' @description produces a summary for all of the objects on the
#' main mapvizieR object.  specifically returns \code{mapvizieR_growth_summary}
#' and \code{mapvizieR_cdf_summary}
#' 
#' @param object a \code{mapvizieR} object
#' @param ... other arguments to be passed to other functions (not currently supported)
#' 
#' @return summary stats as a \code{mapvizier_summary} object.
#' @export

summary.mapvizieR <- function(object, ...){
  
  out <- list(
    'growth_summary' = summary(object$growth_df),
    'cdf_summary' = summary(object$cdf)
  )
  
  class(out) <- c("mapvizieR_summary", class(out))
  
  out
}

#' @title summary method for \code{mapvizieR_growth} class
#'
#' @description
#'  summarizes growth data from \code{mapvizieR_growth} object.
#'
#' @details Creates a \code{mapvizier_growth_summary} object of growth data from a \code{mapvizieR} 
#' object.  Includes the following summarizations for every growth term available
#' in the \code{mapvizier_growth} object:
#' \itemize{
#'  \item number tested in both assessment seasons (i.e., the number of students who 
#'  too a test in both assessment season and for which we are able to calcualate growth stats).
#'  \item Total students making typical growth
#'  \item Percent of students making typical growth
#'  \item Total students making college ready growth
#'  \item Percent of students making college ready  growth
#'  \item Total students with NPR >= 50 percentile in the first assessment season
#'  \item Percent students with NPR >= 50 percentile in the first assessment season
#'  \item Total students with NPR >= 75th percentile in the first assessment season
#'  \item Percent students with NPR >= 75 percentile in the first assessment season
#'  \item Total students with NPR >= 50 percentile in the second assessment season
#'  \item Percent students with NPR >= 50 percentile in the second assessment season
#'  \item Total students with NPR >= 75th percentile in the second assessment season
#'  \item Percent students with NPR >= 75 percentile in the second assessment season
#' } 

#' @param object a \code{mapvizieR_growth} object
#' @param ... other arguments to be passed to other functions (not currently supported)
#' @return summary stats as a \code{mapvizier_summary} object.

#' @export

summary.mapvizieR_growth <- function(object, ...) {
  
  #fix for s3 consistency cmd check (http://stackoverflow.com/a/9877719/561698)
  if (!hasArg(digits)) {
    digits <- 2
  } else {
    digits <- list(...)$digits
  }
  
  #summary.mapvizieR_cdf requires grouping vars on the cdf
  #process_cdf_long sets them as part of construction of the mv object
  #if there are NO grouping vars, this will set them by default
  existing_groups <- dplyr::group_vars(object)
  
  if (is.null(existing_groups)) {
    object <- object %>%
      dplyr::group_by(
        end_map_year_academic, cohort_year, growth_window, end_schoolname,
        start_grade, end_grade,
        start_fallwinterspring, end_fallwinterspring,
        measurementscale
      )      
  }
  
  #but there are some minimal fields needed to make the CGP calcs go (issue #317)
  #force these
  required <- c(
    'measurementscale',  
    'start_map_year_academic', 'start_grade', 'start_fallwinterspring', 
    'end_map_year_academic', 'end_grade', 'end_fallwinterspring', 
    'growth_window'
  )
  required_test <- required %in% existing_groups
  
  if (!all(required_test)) {
    all_groups <- c(required, existing_groups) %>% unique()
    object <- object %>% dplyr::group_by_(.dots = all_groups)
  }
  
  mapSummary <- object %>% 
    dplyr::filter(complete_obsv) %>%
    dplyr::summarize(
      n_students = n(),
      n_typical = sum(met_typical_growth, na.rm = TRUE),
      pct_typical = round(n_typical/n_students, digits),
      n_accel_growth = sum(met_accel_growth, na.rm = TRUE),
      pct_accel_growth = round(n_accel_growth/n_students,digits),
      n_negative = sum(growth_status == "Negative", na.rm = TRUE),
      pct_negative = round(n_negative/n_students, digits),
      start_n_50th_pctl = sum(start_testpercentile >= 50, na.rm = TRUE),
      start_pct_50th_pctl = round(start_n_50th_pctl / n_students, digits),
      end_n_50th_pctl = sum(end_testpercentile >= 50, na.rm = TRUE),
      end_pct_50th_pctl = round(end_n_50th_pctl / n_students,digits),
      start_n_75th_pctl = sum(start_testpercentile >= 75, na.rm = TRUE),
      start_pct_75th_pctl = round(start_n_75th_pctl/n_students,digits),
      end_n_75th_pctl = sum(end_testpercentile >= 75, na.rm = TRUE),
      end_pct_75th_pctl = round(end_n_75th_pctl / n_students,digits),
      start_mean_testritscore = round(mean(start_testritscore, na.rm = TRUE), digits),
      end_mean_testritscore = round(mean(end_testritscore, na.rm = TRUE), digits),
      mean_rit_growth = round(mean(rit_growth, na.rm = TRUE), digits),
      mean_cgi = round(mean(cgi, na.rm = TRUE), digits),
      mean_sgp = pnorm(mean_cgi),
      start_median_testritscore = round(median(start_testritscore, na.rm = TRUE), digits),
      end_median_testritscore = round(median(end_testritscore, na.rm = TRUE), digits),
      median_rit_growth = round(median(rit_growth, na.rm = TRUE), digits),
      median_cgi = round(median(cgi, na.rm = TRUE), digits),
      median_sgp = round(median(sgp, na.rm = TRUE), digits),
      start_median_consistent_percentile = round(median(start_consistent_percentile, na.rm = TRUE), digits),
      end_median_consistent_percentile = round(median(end_consistent_percentile, na.rm = TRUE), digits)
    )
  
  mapSummary <- mapSummary %>%
    dplyr::rowwise() %>%
    dplyr::mutate(
      cgp = calc_cgp(
        measurementscale, end_grade, growth_window, start_mean_testritscore, end_mean_testritscore
      )[['results']] %>% round(digits)
    )

  mapSummary$start_cohort_status_npr <- NA_integer_
  mapSummary$end_cohort_status_npr <- NA_integer_
  
  for (i in 1:nrow(mapSummary)) {
    mapSummary[i, ]$start_cohort_status_npr <- cohort_mean_rit_to_npr(
      mapSummary[i, ]$measurementscale, 
      mapSummary[i, ]$start_grade, 
      mapSummary[i, ]$start_fallwinterspring,
      mapSummary[i, ]$start_mean_testritscore
    ) 
    
    mapSummary[i, ]$end_cohort_status_npr <- cohort_mean_rit_to_npr(
      mapSummary[i, ]$measurementscale, 
      mapSummary[i, ]$end_grade, 
      mapSummary[i, ]$end_fallwinterspring,
      mapSummary[i, ]$end_mean_testritscore
    )     
  }
  
  class(mapSummary) <- c("mapvizieR_growth_summary", class(mapSummary))
  
  #return
  mapSummary
}


#' @title summary method for \code{mapvizieR_cdf} class
#'
#'
#' @param object a \code{mapvizieR_cdf} object
#' @param ... other arguments to be passed to other functions (not currently supported)

#' @return summary stats as a \code{mapvizier_cdf_summary} object.

#' @export

summary.mapvizieR_cdf <- function(object, ...) {
  
  #summary.mapvizieR_cdf requires grouping vars on the cdf
  #process_cdf_long sets them as part of construction of the mv object
  #if there are NO grouping vars, this will set them by default
  existing_groups <- dplyr::group_vars(object)
  
  if (is.null(existing_groups)) {
    object <- object %>%
      dplyr::group_by(
        measurementscale, map_year_academic, fallwinterspring, 
        termname, schoolname, grade, grade_level_season)      
  }
    
  #but there are some minimal fields needed to make the CGP calcs go (issue #317)
  #force these
  required <- c(
    'measurementscale',  
    'map_year_academic', 'fallwinterspring', 'termname', 
    'grade', 'grade_level_season'
  )
  required_test <- required %in% existing_groups
  
  if (!all(required_test)) {
    all_groups <- c(required, existing_groups) %>% unique()
    object <- object %>% dplyr::tbl_df() %>% dplyr::group_by_(.dots = all_groups)
  }
  
  df <- object %>%
    dplyr::summarize(
      mean_testritscore = mean(testritscore, na.rm = TRUE),
      mean_percentile = mean(consistent_percentile, na.rm = TRUE),
      n_students = n(),
      pct_50th_pctl = round(sum(consistent_percentile >= 50)/n(),2),
      pct_75th_pctl = round(sum(consistent_percentile >= 75)/n(),2)
    ) 
  
  df$cohort_status_npr <- rep(NA_integer_, nrow(df))
  
  if (nrow(df) > 0) {
    for (i in 1:nrow(df)) {
      df[i, ]$cohort_status_npr <- cohort_mean_rit_to_npr(
        df[i, ]$measurementscale, 
        df[i, ]$grade, 
        df[i, ]$fallwinterspring,
        df[i, ]$mean_testritscore
      )
    }    
  }
  
  class(df) <- c("mapvizieR_cdf_summary", class(df))
  
  df
}
