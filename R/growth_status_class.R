
growth_status_scatter_class <- function(
  growth_summary
) {
  
  annotation_df <- data.frame(
    lab_x = c(33/2, 50, 66 + 33/2, 33/2, 50, 66 + 33/2),
    lab_y = c(75, 75, 75, 25, 25, 25),
    lab_text = c(
      'Low Growth\nAbove Gr. Lev.', 'Avg Growth\nAbove Gr. Lev.',
      'High Growth\nAbove Gr. Lev.', 'Low Growth\nBelow Gr. Lev.',
      'Avg Growth\nBelow Gr. Lev.', 'High Growth\nBelow Gr. Lev.'
    )
  )
  
  #plot
  p <- ggplot(
    data = growth_summary,
    aes(
      x = cgp,
      y = end_cohort_status_npr,
      label = class_name,
      color = is_highlight
    )
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
      size = rel(3), alpha = .8
    ) +
    geom_jitter(
      size = 3, shape = 1, position = position_jitter(height = 0.75, width = .75),
      alpha = .8
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
    scale_color_manual(values = c('red', 'black')) +
    #labels
    labs(
      x = 'Class/Grade Growth Percentile', 
      y = 'Class/Grade Attainment Percentile'
    ) +
    theme(
      plot.title = element_text(hjust = 0, face = "bold", size = 20),
      panel.background = element_blank(),
      panel.grid.major = element_line(
        color = 'gray95',
        linetype = 'longdash',
        size = 0.25
      ),
      legend.position = 'none'
    )
  
  return(p)

}

foo <- function() {
  
  #gsum <- mapvizieR:::summary.mapvizieR_growth(mapviz$growth_df)
  gsum$class_name <- paste(gsum$end_schoolname, gsum$end_grade)
  gsum$is_highlight <- gsum$end_schoolname == 'St. Helens Elementary School'
  
  growth_status_scatter_class(
    gsum %>% dplyr::filter(
      measurementscale == 'Reading' & 
      end_map_year_academic == 2013 &
      end_grade == 5)
  )
  
}