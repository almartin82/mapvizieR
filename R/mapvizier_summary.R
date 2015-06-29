#' @title summary method for \code{mapvizieR} class
#'
#' @description
#'  summarizes growth data from \code{mapvizieR} orbect.
#'
#' @details Creates a \code{mapvizier_summary} object of growth data from a \code{mapvizieR} 
#' object.  Includes the following summarizations for every growth term available
#' in the \code{mapvizier} object:
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

#' @param mapvizieR_object a \code{mapvizieR} object
#' @param ... other arguments to be passed to other functions (not currently supported)
#' @param digits the numbber of digits to round percentatges to. 

#' @return summary stats as a \code{mapvizier_summary} object.
#' @rdname summary
#' @export


summary.mapvizieR <- function(mapvizieR_object, ..., digits = 2){
  
  
  df <- as.data.frame(mapvizieR_object$growth_df) %>%
    dplyr::mutate(cohort_year = end_map_year_academic + 1 + 12 - end_grade) %>%
    dplyr::group_by(end_map_year_academic, 
                    cohort_year,
                    growth_window, 
                    end_schoolname, 
                    end_grade, 
                    measurementscale
    )
    
    
  mapSummary <- dplyr::summarize(df,
                                 n_students = n(),
                                 n_typical = sum(met_typical_growth),
                                 pct_typical = round(sum(met_typical_growth)/n_students,digits),
                                 n_accel_growth = sum(met_accel_growth),
                                 pct_accel_growth = round(sum(n_accel_growth)/n_students,digits),
                                 n_negative = sum(growth_status == "Negative"),
                                 pct_negative = round(n_negative/n_students, digits),
                                 start_n_50th_pctl = sum(start_testpercentile >= 50),
                                 start_pct_50th_pctl = round(sum(start_n_50th_pctl) / n_students, digits),
                                 end_n_50th_pctl = sum(end_testpercentile >= 50),
                                 end_pct_50th_pctl = round(sum(start_testpercentile) / n_students,digits),
                                 start_n_75th_pctl = sum(start_testpercentile >= 75),
                                 start_pct_75th_pctl = round(sum(start_n_75th_pctl)  /n_students,digits),
                                 end_n_75th_pctl = sum(start_testpercentile >= 75),
                                 end_pct_75th_pctl = round(sum(end_n_75th_pctl) / n_students,digits),
                                 start_mean_testritscore = round(mean(start_testritscore, na.rm = TRUE), digits),
                                 end_mean_testritscore = round(mean(end_testritscore, na.rm = TRUE), digits),
                                 mean_rit_growth = round(mean(rit_growth, na.rm = TRUE), digits),
                                 mean_cgi = round(mean(cgi,na.rm = TRUE), digits)
  )
  
  class(mapSummary) <- c("mapvizieR_summary", class(mapSummary))
  
  #return
  mapSummary
  
}