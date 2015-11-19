


historic_recap_report <- function(
  mapvizieR_obj,
  studentids,
  measurementscale,
  target_percentile = 75,
  first_and_spring_only = TRUE,
  entry_grade_seasons = c(-0.8, 4.2)
) {
 
  p75 <- historic_nth_percentile_plot(  
    mapvizieR_obj,
    studentids,
    measurementscale,
    target_percentile,
    first_and_spring_only,
    entry_grade_seasons
  )
  
  template_05(p75, p75)
}