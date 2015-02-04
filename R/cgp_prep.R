
#' @title calc_cgp_targets
#' 
#' @description given a baseline, what scores are necessary to reach certain growth targets
#' 
#' @param measurementscale MAP subject
#' @param grade baseline/starting grad for the group of students
#' @param growth_window desired growth window for targets (fall/spring, spring/spring, fall/fall)
#' @param baseline_avg_rit the baseline mean rit for the group of students
#' @param tolerance NWEA has published empirical lookup tables for growth.  these tables cover 
#' the middle of the distribution, meaning that data for most cohorts can be found in the table.
#' but say that you have a cohort that is 10 rit points below the lowest mean RIT reported in the 
#' tables?  do you just use the lowest entry?  
#' mapvizieR has a generalization of the school growth study that translate the RIT changes to 
#' percentile change, and then fits a general model to express cohort growth percentile 
#' given a starting percentile and an ending percentile. rather than use lookup tables that we 
#' know to be poor fits to the students  
#' 
#' @param school_growth_study

calc_cgp_targets <- function(
  measurementscale
 ,grade
 ,growth_window
 ,baseline_avg_rit
 ,tolerance=10
 ,sch_growth_study=sch_growth_norms_2012
) {
  
  calc_for <- c(1:99)
  
  cgp_method <- determine_cgp_method(
    measurementscale, grade, growth_window, baseline_avg_rit, tolerance, sch_growth_study
  )

  
}


determine_cgp_method <- function(
  measurementscale
 ,grade
 ,growth_window
 ,baseline_avg_rit
 ,tolerance
 ,sch_growth_study
) {
  #if this is science, use the generalization
  if (measurementscale == 'General Science') {
    return('cgp_generalization')
  }
  
  norm_match <- sch_growth_study %>%
    filter(
      measurementscale==measurementscale
     ,growth_window==growth_window
     ,grade==grade
    )
  
  diffs <- baseline_avg_rit - norm_match$rit
  #if the rit difference is greater than the tolerance, use generalization
  if (max(abs(diffs)) > tolerance) {
    return('cgp_generalization')
  #otherwise look it up 
  } else {
    return('cgp_nearest_lookup')
  }

}