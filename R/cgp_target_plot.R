cgp_target_spread_plot <- function(cgp_prep) {
  
  df <- cgp_prep$targets
  df$base_rit <- cgp_prep$expectations$observed_baseline
  df$start_grade <- cgp_prep$expectations$start_grade_level_season
  df$end_grade <- cgp_prep$expectations$end_grade
  
  x_seq <- c(cgp_prep$expectations$start_grade_level_season, cgp_prep$expectations$end_grade)
  
  df <- df %>%
    dplyr::mutate(
      end_rit = base_rit + growth_target,
      sign = ifelse(growth_target >= 0, '+', '-'),
      signed_growth_target = paste(sign, round(abs(growth_target), 1))
    )
  
  p <- ggplot(
    data = df,
    aes(
      x = start_grade,
      y = base_rit,
      xend = end_grade,
      yend = end_rit,
      label = paste0('CGP ', cgp, ', ', signed_growth_target)
    )
  ) +
  geom_segment() +
  geom_text(
    aes(
      x = cgp_prep$expectations$end_grade,
      y = end_rit
    ),
    hjust = 0
  ) +
  theme_bw() +
  theme(panel.grid = element_blank()) +
  labs(
    x = 'Grade Level',
    y = 'Cohort Mean RIT'
  ) +
  scale_x_continuous(
    breaks = x_seq,
    labels = lapply(x_seq, fall_spring_me) %>% unlist(),
    limits = c(x_seq[1] - .05, x_seq[2] + .3)
  )   
  
  p
}