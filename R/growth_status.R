#' @title growth status scatter
#'
#' @param mapvizieR_obj mapvizieR object
#' @param studentids target students
#' @param measurementscale target subject
#' @param start_fws starting season
#' @param start_academic_year starting academic year
#' @param end_fws ending season
#' @param end_academic_year ending academic year
#' 
#' @return a ggplot object
#' 
#' @export

growth_status_scatter <- function(
  mapvizieR_obj,
  studentids,
  measurementscale,
  start_fws,
  start_academic_year,
  end_fws,
  end_academic_year
) {
  #NSE problems
  measurementscale_in <- measurementscale

  #data
  goal_df <- mapvizieR_obj[['growth_df']] %>%
    dplyr::filter(
      measurementscale == measurementscale_in & studentid %in% studentids
    ) %>%
    dplyr::filter(
      (end_map_year_academic == end_academic_year & end_fallwinterspring == end_fws) 
    ) %>%
    dplyr::filter(
      (start_map_year_academic == start_academic_year & start_fallwinterspring == start_fws) 
    )
  #add student name
  goal_df <- goal_df %>%
    dplyr::left_join(
      mapvizieR_obj[['roster']] %>%
        dplyr::select(
          studentid, studentfirstlast
        ),
      by = 'studentid'
    )
  
  annotation_df <- data.frame(
    lab_x = c(33/2, 50, 66 + 33/2, 33/2, 50, 66 + 33/2)
   ,lab_y = c(75, 75, 75, 25, 25, 25)
   ,lab_text = c(
     'Low Growth\nAbove Gr. Lev.', 'Avg Growth\nAbove Gr. Lev.',
     'High Growth\nAbove Gr. Lev.', 'Low Growth\nBelow Gr. Lev.',
     'Avg Growth\nBelow Gr. Lev.', 'High Growth\nBelow Gr. Lev.'
    )
  )
  
  #plot
  p <- ggplot(
     data = goal_df,
     aes(
       x = sgp * 100,
       y = end_testpercentile,
       label = studentfirstlast
     )
   ) +
   #need a layer
   geom_point(
    alpha = 0 
   ) 
  
  #add annotations
  p <- p + annotate(
    geom = 'text',
    x = annotation_df$lab_x,
    y = annotation_df$lab_y,
    label = annotation_df$lab_text,
    size = 9,
    color = 'gray80',
    alpha = 0.8
  )
  
  #stu scatter
  p <- p +              
   geom_vline(
     xintercept = c(34,66), size = 0.5, color = 'gray50', alpha = .6
   ) +
   geom_hline(
     yintercept = c(50), size = 0.5, color = 'gray50', alpha = .6 
   ) +
   #chart elements
   geom_text(
     size = rel(3), alpha = .4, color = 'gray10'
   ) +
   geom_jitter(
     size = 2, shape = 1, position = position_jitter(height = 0.75, width = .75),
     alpha = .4, color = 'gray50'
   ) +
   #scale
   coord_cartesian(
     ylim = c(0, 100), xlim = c(0,100)
   ) +
   scale_x_continuous(
     breaks = seq(10, 90, by = 10), minor_breaks = NULL
   ) +
   scale_y_continuous(
     breaks = seq(10, 90, by = 10), minor_breaks = NULL
   ) +
   #labels
   labs(
     x = 'Growth Percentile', 
     y = 'Percentile Rank'
   ) +
   theme(
     plot.title = element_text(hjust = 0, face = "bold", size = 20),
     panel.background = element_blank(),
     panel.grid.major = element_line(
       color = 'gray95',
       linetype = 'longdash',
       size = 0.25
     )
   )
  return(p)
}


