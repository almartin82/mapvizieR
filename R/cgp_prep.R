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
 ,baseline_avg_npr
 ,tolerance=10
 ,sch_growth_study=sch_growth_norms_2012
 ,calc_for=c(1:99)
) {
  #cant have a growth percentile 0 or below, or 100 or above.

  #get the method
  cgp_method <- determine_cgp_method(
    measurementscale, grade, growth_window, baseline_avg_rit, tolerance, sch_growth_study
  )

  #do.call the appropriate method.  returns df.
  do.call(
    what=paste0('cohort_expectation_via_', cgp_method),
    args=list(
      measurementscale_in=measurementscale,
      grade_in=grade,
      growth_window_in=growth_window,
      baseline_avg_rit=baseline_avg_rit,
      calc_for=calc_for
    )
  )
    
}



#' @title cohort_expectation_via_lookup
#' 
#' @description wrapper function to get cohort growth expectations for the lookup method
#' 
#' @inheritParams project_cgp_targets

cohort_expectation_via_lookup <- function(
  measurementscale_in
 ,grade_in
 ,growth_window_in
 ,baseline_avg_rit
 ,baseline_avg_npr
 ,sch_growth_study
 ,calc_for
) {
  
  #get expectation
  growth_expectation <- do.call(
    what=sch_growth_lookup,
    args=list(
      measurementscale_in=measurementscale_in,
      grade_in=grade_in,
      growth_window_in=growth_window_in,
      baseline_avg_rit=baseline_avg_rit
    )
  )

  #calc targets over range
  growth_target <- lapply(
    X=calc_for, 
    FUN=rit_gain_needed, 
    sd_gain=growth_expectation[['sd_of_expectation']], 
    mean_gain=growth_expectation[['typical_cohort_growth']]
  ) %>% unlist()


  #return df
  data.frame(
    cgp=calc_for,
    z_score=qnorm(calc_for/100),
    growth_target=growth_target,
    measured_in='RIT'
  )
}





#' @title cohort_expectation_via_generalization
#' 
#' @description expectation in NPR via generalization
#' 
#' @inheritParams project_cgp_targets

cohort_expectation_via_generalization <- function(
  measurementscale_in
 ,grade_in
 ,growth_window_in
 ,baseline_avg_rit
 ,baseline_avg_npr
 ,sch_growth_study
 ,calc_for
){
  #these only work for spring to spring...
  #some assert here
  
  #apply over calc_for
  growth_target <- lapply(
    X=calc_for, 
    FUN=percentile_gain_needed, 
    grade_level=grade_in,
    start_npr=baseline_avg_npr
  ) %>% unlist()
  
  #return df
  data.frame(
    cgp=calc_for,
    z_score=qnorm(calc_for/100),
    growth_target=growth_target,
    measured_in='NPR'
  )
  
} 



#' @title rit_gain_needed
#' 
#' @description rit gain needed to reach given percentile
#' 
#' @param percentile growth percentile, between 0-100
#' @param sd_gain sd for population growth
#' @param mean_gain typical growth for population

rit_gain_needed <- function(percentile, sd_gain, mean_gain) {
  z <- qnorm((percentile/100))
  (z * sd_gain) + mean_gain
}



#' @title percentile_gain_needed
#' 
#' @description called by generalization method.
#' 
#' @param grade_in, start_npr, target_cgp

percentile_gain_needed <- function(target_cgp, grade_level, start_npr) {
    # transform cgp to logit scale (0-1)
    target_cgp = target_cgp/100

    # thanks wolfram alpha http://bit.ly/1dYmWqY
    npr_change <- ((0.134056 * grade_level) + (-0.0574764 * start_npr) + log(-((12.583 * 
        target_cgp)/(target_cgp - 1))))/0.292364

    return(round(npr_change, 1))
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



#' @title sch_growth_lookup
#' 
#' @description get cohort growth expectations via lookup from growth study
#' 
#' @param measurementscale MAP subject
#' @param grade baseline/starting grad for the group of students
#' @param growth_window desired growth window for targets (fall/spring, spring/spring, fall/fall)
#' @param baseline_avg_rit the baseline mean rit for the group of students
#' @param sch_growth_study NWEA school growth study to use for lookup; defaults to 2012.

sch_growth_lookup <- function(  
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
  
  as.list(norm_match[best_match==1, ])

}
