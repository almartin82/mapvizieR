
cohort_status_trace_plot <- function(
  mapvizieR_obj,
  studentids,
  measurementscale,
  match_method = 'no matching',
  first_and_spring_only = TRUE,
  entry_grade_seasons = c(-0.8, 4.2),
  plot_labels = 'RIT'
) {
  
  #opening
  mv_opening_checks(mapvizieR_obj, studentids, 1)
  this_cdf <- mv_limit_cdf(mapvizieR_obj, studentids, measurementscale)
  
  #summary
  this_sum <- summary(this_cdf)
   
}