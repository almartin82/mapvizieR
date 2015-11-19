


historic_recap_report <- function(
  mapvizieR_obj,
  studentids,
  measurementscale,
  target_percentile = 75,
  first_and_spring_only = TRUE,
  entry_grade_seasons = c(-0.8, 4.2),
  small_n_cutoff = 0.2,
  min_cohort_size = -1
) {
 
  p_75 <- historic_nth_percentile_plot(  
    mapvizieR_obj = mapvizieR_obj,
    studentids = studentids,
    measurementscale = measurementscale,
    target_percentile = target_percentile,
    first_and_spring_only = first_and_spring_only,
    entry_grade_seasons = entry_grade_seasons,
    small_n_cutoff = small_n_cutoff
  )
  
  p_cgp <- multi_cohort_cgp_hist_plot2(
    mapvizieR_obj = mapvizieR_obj,
    studentids = studentids,
    measurementscale = measurementscale,
    first_and_spring_only = first_and_spring_only,
    entry_grade_seasons = entry_grade_seasons,
    small_n_cutoff = small_n_cutoff,
    min_cohort_size = min_cohort_size
  )
  
  template_05(p_75, p_cgp)
}