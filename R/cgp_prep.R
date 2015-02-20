#' @title project_cgp_targets
#' 
#' @description given a baseline, what scores are necessary to reach certain growth targets
# '
#' @param measurementscale MAP subject
#' @param grade baseline/starting grad for the group of students
#' @param growth_window desired growth window for targets (fall/spring, spring/spring, fall/fall)
#' @param baseline_avg_rit the baseline mean rit for the group of students
#' @param baseline_avg_npr the baseleine mean percentile rank for the group of students
#' @param tolerance NWEA has published empirical lookup tables for growth.  these tables cover 
#' the middle of the distribution, meaning that data for most cohorts can be found in the table.
#' but say that you have a cohort that is 10 rit points below the lowest mean RIT reported in the 
#' tables?  do you just use the lowest entry?  
#' mapvizieR has a generalization of the school growth study that translate the RIT changes to 
#' percentile change, and then fits a general model to express cohort growth percentile 
#' given a starting percentile and an ending percentile. rather than use lookup tables that we 
#' know to be poor fits to the students 
#' @param sch_growth_study a school growth study to use.  default is sch_growth_norms_2012
#' @param calc_for vector of cgp targets to calculate for.

project_cgp_targets <- function(
  measurementscale
 ,grade
 ,growth_window
 ,baseline_avg_rit=NA
 ,baseline_avg_npr=NA
 ,tolerance=10
 ,sch_growth_study=sch_growth_norms_2012
 ,calc_for=c(1:99)
) {
  #cant have a calc_for value 0 or below, or above 100 - those aren't valid growth %iles.
  calc_for %>%
    ensure_that(
      min(.) > 0,
      max(.) < 100,
      fail_with = function(...) {
        stop("You must specify *either* a baseline RIT or a baseline NPR.", call. = FALSE)
      }
    )
  
  #you have to specify AT LEAST one of baseline_rit or baseline_npr
  c(is.na(baseline_avg_rit), is.na(baseline_avg_npr)) %>%
    ensure_that(
      !all(.),
      fail_with = function(...) {
        stop("You must specify *either* a baseline RIT or a baseline NPR.", call. = FALSE)
      }
    )
      
  #start of growth window
  start_season <- str_sub(growth_window, 1, str_locate(growth_window, ' ')[1]-1)
  
  #if one of the baselines are NA, look up the value.
  if (is.na(baseline_avg_npr)) {
    baseline_avg_npr <- rit_to_npr(measurementscale, grade, start_season, baseline_avg_rit)    
  }
  
  if (is.na(baseline_avg_rit)) {
    baseline_avg_rit <- npr_to_rit(measurementscale, grade, start_season, baseline_avg_npr)
  }
    
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
      baseline_avg_npr=baseline_avg_npr,
      calc_for=calc_for
    )
  )
    
}



#' @title cohort_expectation_via_lookup
#' 
#' @description wrapper function to get cohort growth expectations for the lookup method
#' 
#' @param measurementscale_in a MAP subject
#' @param grade_in the ENDING grade level for the growth window.  ie, if this calculation
#' crosses school years, use the grade level for the END of the term, per the example on p. 7
#' of the 2012 school growth study
#' @growth_window_in the growth window to calculate CGP over
#' @param baseline_avg_rit mean rit at the START of the growth window
#' @param baseline_avg_npr mean npr at the START of the growth window
#' @param sch_growth_study which school growth study to use.  currently only have the 2012 data
#' files in the package
#' @param calc_for what CGPs to calculate for?


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
#' @inheritParams cohort_expectation_via_lookup

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
#' @description given a CGP target, tells you how much improvement in class percentile 
#' rank neeeded
#' 
#' @param target_cgp the CGP target
#' @param grade_level grade level (end of window)
#' @param start_npr avg start percentile rank

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
#' @param grade_in baseline/starting grad for the group of students
#' @param growth_window_in desired growth window for targets (fall/spring, spring/spring, fall/fall)
#' @param baseline_avg_rit the baseline mean rit for the group of students
#' @param tolerance threshold to depart from lookup to generalization
#' @param sch_growth_study which NWEA school growth study to use

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
#' @param measurementscale_in MAP subject
#' @param grade_in baseline/starting grade for the group of students
#' @param growth_window_in desired growth window for targets (fall/spring, spring/spring, fall/fall)
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



#' @title rit_to_npr
#' 
#' @description given a RIT score, return the best match percentile rank
#' 
#' @param measurementscale MAP subject
#' @param grade grade level
#' @param season fall winter spring
#' @param RIT rit score

rit_to_npr <- function(measurementscale, grade, season, RIT) {
  
  matches <- student_status_norms_2011_dense_extended[with(
    student_status_norms_2011_dense_extended,
    measurementscale==measurementscale & grade==grade & fallwinterspring==season &
      round(RIT, 0)==RIT),]
  
  if (nrow(matches)==0) {
    NA
  } else{
    matches[1, 'percentile']    
  }
}



#' @title npr_to_rit
#' 
#' @description given a percentile rank, return the best match RIT
#' 
#' @param measurementscale MAP subject
#' @param grade grade level
#' @param season fall winter spring
#' @param npr a percentile rank, between 1-99

npr_to_rit <- function(measurementscale, grade, season, npr) {
  
  matches <- student_status_norms_2011_dense_extended[with(
    student_status_norms_2011_dense_extended,
    measurementscale==measurementscale & grade==grade & fallwinterspring==season &
      round(npr, 0)==percentile),]
  
  if (nrow(matches)==0) {
    NA
  } else{
    matches[1, 'RIT']    
  }
}