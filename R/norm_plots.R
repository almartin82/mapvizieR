#' @title empty norm grade space
#'
#' @description
#' shows the norm space across grade levels or a given subject
#' @param measurementscale a NWEA map measurementscale
#' @param trace_lines vector of percentiles to show.  must be between 1 and 99.
#' @param norms which norm study to use
#' @param norm_linetype any valid ggplot linetype (eg 'dashed').  
#' default is 'solid'.
#' @param spring_only fall norms show a 'summer slump' effect; this can be
#' visually distracting.  spring_only won't include those points in the reference
#' lines.
#' 
#' @export

empty_norm_grade_space <- function(
  measurementscale, 
  trace_lines = c(5, 10, 20, 30, 40, 50, 60, 70, 80, 90, 95),
  norms = 2015,
  norm_linetype = 'solid',
  spring_only = FALSE
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
  
  if (spring_only) {
    this_norms <- this_norms %>%
      dplyr::ungroup() %>%
      dplyr::filter(
        fallwinterspring == 'Spring' | grade_level_season == -0.8
      )
  }
  
  p <- ggplot(
    data = this_norms
  ) +
  geom_line(
    aes(
      x = grade_level_season,
      y = RIT,
      group = student_percentile,
      order = 1
    ),
    alpha = 0.3,
    color = 'gray30',
    linetype = norm_linetype
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
    breaks = this_norms$grade_level_season %>% unique() %>% sort(),
    labels = this_norms$grade_level_season %>% unique() %>% sort() %>%
      lapply(fall_spring_me) %>% unlist()
  ) +
  theme(
    panel.grid = element_blank()
  )
  
  return(p)
}
