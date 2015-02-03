

cgp_targets <- function(
  growth_window
 ,measurementscale
 ,grade
 ,baseline_avg_rit
 ,tolerance
 ,sch_growth_study=sch_growth_norms_2012
) {
  
  calc_for <- c(1:99)
  
  cgp_method <- determine_cgp_method(
    growth_window, measurementscale, grade, baseline_avg_rit, tolerance, sch_growth_study
  )

  
}


determine_cgp_method <- function(
  growth_window
 ,measurementscale
 ,grade
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