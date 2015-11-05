#' Longitudinal plot against NPR background
#'
#' @description shows the progress of students, and cohort average, against
#' the NPR space.
#'
#' @param mapvizieR_obj a conforming mapvizieR object
#' @param studentids a vector of studentids
#' @param measurementscale target subject
#' @param first_and_spring_only logical, should we include fall/winter scores
#' from non-entry grades?
#' @param entry_grade_seasons what grades are 'entry' grades for this school? 
#' @param student_norms which student norms for template?
#' @param student_alpha how much to alpha-out the student observations?
#' @param trace_lines what norms to show?
#'
#' @return a ggplot object
#' @export

cohort_longitudinal_npr_plot <- function(
  mapvizieR_obj,
  studentids,
  measurementscale,
  first_and_spring_only = TRUE,
  entry_grade_seasons = c(-0.8, 4.2), 
  student_norms = 2015,
  student_alpha = 0.1,
  trace_lines = c(1, 10, 20, 30, 40, 50, 60, 70, 80, 90, 99)
) {
  #template
  template <- empty_norm_grade_space(
    measurementscale = measurementscale,
    trace_lines = trace_lines,
    norms = student_norms,
    norm_linetype = 'dotted'
  )
  
  #limit to these students, subject, and entry grade logic
  this_cdf <- mv_limit_cdf(mapvizieR_obj, studentids, measurementscale)
  this_cdf <- valid_grade_seasons(
    this_cdf, first_and_spring_only, entry_grade_seasons, 9999
  )
  this_cdf$type <- 'Student'
  
  grouped <- this_cdf %>%
    dplyr::group_by(
      grade_level_season
    ) %>%
    dplyr::summarize(
      testritscore = mean(testritscore, na.rm = TRUE)
    )
  grouped$type <- 'Cohort'
  grouped$studentid <- 'Cohort'
  
  final_cdf <- rbind(
    grouped,
    this_cdf %>% 
      dplyr::select(type, grade_level_season, testritscore, studentid)
  )
  
  out <- template + 
  geom_point(
    data = final_cdf,
    aes(
      x = grade_level_season,
      y = testritscore,
      group = studentid,
      color = type,
      size = type,
      alpha = type
    )
  ) +
  geom_line(
    data = final_cdf,
    aes(
      x = grade_level_season,
      y = testritscore,
      group = studentid,
      color = type,
      size = type,
      alpha = type
    )
  ) +    
  scale_size_manual(values = c(3, 1)) +
  scale_alpha_manual(values = c(1, student_alpha)) +
  scale_color_manual(values = c('red2', 'darkblue')) +
  theme_bw() +
  theme(
    panel.grid = element_blank()
  ) +
  coord_cartesian(
    xlim = c(
      this_cdf$grade_level_season %>% min() %>% 
        round_to_any(accuracy = 1, f = floor) - 0.05, 
      this_cdf$grade_level_season %>% max() %>%
        round_to_any(accuracy = 1, f = ceiling) + 0.05
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