#' @title empty norm grade space
#'
#' @description
#' shows the norm space across grade levels or a given subject
#' @param measurementscale a NWEA map measurementscale
#' @param trace_lines vector of percentiles to show.  must be between 1 and 99.
#' @param norms which norm study to use
#' 
#' @export

empty_norm_grade_space <- function(
  measurementscale, 
  trace_lines = c(5, 10, 20, 30, 40, 50, 60, 70, 80, 90, 95),
  norms = 2015
)  {

  if (norms == 2011) {
    active_norms <- student_status_norms_2011_dense_extended
  } else if (norms == 2015) {
    active_norms <- student_status_norms_2015_dense_extended
  }  
  this_norms <- active_norms %>%
    dplyr::filter(
      measurementscale == get("measurementscale") &
      student_percentile %in% trace_lines
    )
  this_norms <- grade_level_seasonify(this_norms)
  #low and high
  below_50 <- this_norms %>% dplyr::filter(student_percentile < 50)
  above_50 <- this_norms %>% dplyr::filter(student_percentile >= 50)
  below_50 <- below_50 %>% 
    dplyr::group_by(
      measurementscale, fallwinterspring, grade, 
      grade_level_season, student_percentile
    ) %>%
    dplyr::summarize(
      RIT = max(RIT) 
    )
  above_50 <- above_50 %>% 
    dplyr::group_by(
      measurementscale, fallwinterspring, grade, grade_level_season, student_percentile
    ) %>%
    dplyr::summarize(
      RIT = min(RIT) 
    )
  this_norms <- rbind(below_50, above_50)
  
  p <- ggplot(
    data = this_norms
  ) +
  geom_line(
    aes(
      x = grade_level_season,
      y = RIT,
      group = student_percentile
    ),
    alpha = 0.3,
    color = 'gray30'
  ) +
  geom_text(
    data = this_norms %>% dplyr::filter(grade_level_season %% 1 == 0),
    aes(
      x = grade_level_season,
      y = RIT,
      label = student_percentile
    ),
    color = 'gray30',
    alpha = 0.3,
    fontface = 'italic'
  ) +
  theme_bw() +
  labs(
    x = 'Grade Level',
    y = 'RIT Score'
  ) +
  scale_x_continuous(
    breaks = c(0:12),
    labels = c(0:12)
  ) + 
  theme(
    panel.grid = element_blank()
  )
  
  p
}
