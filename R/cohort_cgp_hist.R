
foo_variables <- function() {
  
  testing_constants()
  mapvizieR_obj <- mapviz
  studentids <- studentids_normal_use
  measurementscale <- 'Mathematics'
  first_and_spring_only <- TRUE
  school_norms <- 2012

}
  
  
#' Show's a cohort's progress over time, in percentile space.
#'
#' @param mapvizieR_obj conforming mapvizieR obj
#' @param studentids vector of studentids
#' @param measurementscale target subject
#' @param first_and_spring_only show all terms, or only entry & spring?  
#' default is TRUE.
#' @param school_norms c(2012, 2015).  what school norms to use?  default
#' is 2012.
#'
#' @return a ggplot object
#' @export

cohort_cgp_hist_plot <- function(
  mapvizieR_obj,
  studentids,
  measurementscale,
  first_and_spring_only = TRUE,
  school_norms = 2015
) {
  
  #data validation
  mv_opening_checks(mapvizieR_obj, studentids, 1)
  
  #TRANSFORMATION 1 - DATA PROCESSING
  #unpack the mapvizieR object and limit to desired students
  this_cdf <- mv_limit_cdf(mapvizieR_obj, studentids, measurementscale)
  
  
  
}