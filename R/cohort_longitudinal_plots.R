foo_dev <- function() {
  
  testing_constants()
  mapvizieR_obj <- mapviz
  studentids <- studentids_normal_use
  measurementscale <- 'Mathematics'
  first_and_spring_only <- TRUE
  entry_grade_seasons <- c(-0.8, 5.2)
  student_norms <- 2015
 
  cohort_longitudinal_npr_plot(
    mapviz,
    studentids_normal_use,
    'Mathematics'
  ) 
}


cohort_longitudinal_npr_plot <- function(
  mapvizieR_obj,
  studentids,
  measurementscale,
  first_and_spring_only = TRUE,
  entry_grade_seasons = c(-0.8, 4.2), 
  student_norms = 2015
) {
  
  #template
  template <- empty_norm_grade_space(
    measurementscale = measurementscale,
    trace_lines = c(1, 10, 25, 50, 75, 90, 99),
    norms = student_norms 
  )
  
  this_cdf <- mv_limit_cdf(mapvizieR_obj, studentids, measurementscale)
  
  out <- template + 
  geom_point(
    data = this_cdf,
    aes(
      x = grade_level_season,
      y = testritscore,
      group = studentid
    ),
    alpha = 0.1,
    color = 'darkblue'
  ) +
  geom_line(
    data = this_cdf,
    aes(
      x = grade_level_season,
      y = testritscore,
      group = studentid
    ),
    alpha = 0.1,
    color = 'darkblue'
  ) +    
  theme_bw() +
  theme(
    panel.grid = element_blank()
  ) +
  coord_cartesian(
    xlim = c(
      this_cdf$grade_level_season %>% min() %>% 
        round_to_any(accuracy = 1, f = floor) - 0.2, 
      this_cdf$grade_level_season %>% max() %>%
        round_to_any(accuracy = 1, f = ceiling) + 0.2
    ), 
    ylim = c(
      this_cdf$testritscore %>% min() %>% 
        round_to_any(accuracy = 5, f = floor), 
      this_cdf$testritscore %>% max() %>%
        round_to_any(accuracy = 5, f = ceiling)
    )
  ) 
  
  return(out)
  
}