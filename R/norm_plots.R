#' @title empty norm grade space
#'
#' @description
#' shows the norm space across grade levels or a given subject
#' @param measurementscale a NWEA map measurementscale
#' @param trace_lines vector of percentiles to show.  must be between 1 and 99.
#' 
#' @export

empty_norm_grade_space <- function(
  measurementscale, 
  trace_lines = c(5, 10, 20, 30, 40, 50, 60, 70, 80, 90, 95)
)  {

  this_norms <- student_status_norms_2011_dense_extended %>%
    dplyr::filter(
      measurementscale == get("measurementscale") &
      percentile %in% trace_lines
    )
  this_norms <- grade_level_seasonify(this_norms)
  #low and high
  below_50 <- this_norms %>% dplyr::filter(percentile < 50)
  above_50 <- this_norms %>% dplyr::filter(percentile >= 50)
  below_50 <- below_50 %>% 
    dplyr::group_by(
      measurementscale, fallwinterspring, grade, grade_level_season,percentile
    ) %>%
    dplyr::summarize(
      RIT = max(RIT) 
    )
  above_50 <- above_50 %>% 
    dplyr::group_by(
      measurementscale, fallwinterspring, grade, grade_level_season, percentile
    ) %>%
    dplyr::summarize(
      RIT = min(RIT) 
    )
  this_norms <- rbind(below_50, above_50)
  
  p <- ggplot() +
    geom_line(
      data = this_norms,
      aes(
        x = grade_level_season,
        y = RIT,
        group = percentile
      ),
      alpha = 0.15,
      color = 'gray60'
    ) +
    geom_text(
      data = this_norms %>% dplyr::filter(grade_level_season %% 1 == 0),
      aes(
        x = grade_level_season,
        y = RIT,
        label = percentile
      ),
      color = 'gray60',
      alpha = 0.15,
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