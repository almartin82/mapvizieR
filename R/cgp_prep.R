
#' @title project_cgp_targets
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
#' @param school_growth_study a school growth study to use.  default is sch_growth_norms_2012

project_cgp_targets <- function(
  measurementscale
 ,grade
 ,growth_window
 ,baseline_avg_rit
 ,tolerance=10
 ,sch_growth_study=sch_growth_norms_2012
 ,calc_for=c(1:99)
) {

  #get the method
  cgp_method <- determine_cgp_method(
    measurementscale, grade, growth_window, baseline_avg_rit, tolerance, sch_growth_study
  )

  #do.call the method
  
  
  calc_for <- c(1:99)
  
}



#' @title determine_cgp_method
#' 
#' @param measurementscale MAP subject
#' @param grade baseline/starting grad for the group of students
#' @param growth_window desired growth window for targets (fall/spring, spring/spring, fall/fall)
#' @param baseline_avg_rit the baseline mean rit for the group of students
#' @param tolerance threshold to depart from lookup to generalization
#' 
#' @inheritParams project_cgp_targets

determine_cgp_method <- function(
  measurementscale_in
 ,grade_in
 ,growth_window_in
 ,baseline_avg_rit
 ,tolerance
 ,sch_growth_study
) {
  #if this is science, use the generalization
  if (measurementscale_in == 'General Science') {
    return('generalization')
  }
  
  norm_match <- sch_growth_study %>%
    filter(
      measurementscale==measurementscale_in, growth_window==growth_window_in, grade==grade_in
    )
  
  diffs <- baseline_avg_rit - norm_match$rit
  #if the rit difference is greater than the tolerance, use generalization
  if (min(abs(diffs)) > tolerance) {
    return('generalization')
  #otherwise look it up 
  } else {
    return('lookup')
  }
}



#' @title cgp_target_lookup
#' 
#' @description get the best matching row from a school growth study data frame.
#' 
#' @param measurementscale MAP subject
#' @param grade baseline/starting grad for the group of students
#' @param growth_window desired growth window for targets (fall/spring, spring/spring, fall/fall)
#' @param baseline_avg_rit the baseline mean rit for the group of students

cgp_target_lookup <- function(  
  measurementscale_in
 ,grade_in
 ,growth_window_in
 ,baseline_avg_rit
 ,sch_growth_study=sch_growth_norms_2012
) {
    
  norm_match <- sch_growth_study %>%
    filter(
      measurementscale==measurementscale_in, growth_window==growth_window_in, 
        grade==grade_in
    ) %>%
    mutate(
      diff=abs(rit - baseline_avg_rit)
    )
  
  best_match <- rank(norm_match$diff, ties.method=c("first"))
  
  norm_match[best_match==1, ]
}


ex_diamonds <- diamonds[sample(nrow(diamonds), 20), ]
ex_diamonds$rank <- with(ex_diamonds, rank(color, -price))
ex_diamonds[order(ex_diamonds$rank),] 