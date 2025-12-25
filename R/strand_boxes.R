#' @title goal strand boxes
#' 
#' @description a plot that shows multiple goal scores as boxplots
#' 
#' @param mapvizieR_obj mapvizieR object
#' @param studentids target students
#' @param measurementscale target subject
#' @param fws season
#' @param academic_year academic year
#' 
#' @return a ggplot object
#' 
#' @export

strand_boxes <- function(
  mapvizieR_obj,
  studentids,
  measurementscale,
  fws,
  academic_year
) {
  #nse problems
  measurementscale_in <- measurementscale
  
  #data validation and unpack
  mv_opening_checks(mapvizieR_obj, studentids, 1)

  #unpack the mapvizieR object and limit to desired students
  goal_df <- mapvizieR_obj$cdf %>%
    dplyr::ungroup() %>%
    dplyr::filter(
      measurementscale == measurementscale_in & studentid %in% studentids
    ) %>%
    dplyr::filter(
      (map_year_academic == academic_year & fallwinterspring == fws) 
    )

  #trim down to two data frames - one of RITs, one of GOALs.
  stage_1a <- goal_df %>%
    dplyr::select(
      studentid, measurementscale, map_year_academic, fallwinterspring, 
      goal1ritscore, goal2ritscore, goal3ritscore, goal4ritscore,
      goal5ritscore, goal6ritscore, goal7ritscore, goal8ritscore
    )
  
  stage_1b <- goal_df %>%
    dplyr::select(
      studentid, measurementscale, map_year_academic, fallwinterspring, 
      goal1name, goal2name, goal3name, goal4name,
      goal5name, goal6name, goal7name, goal8name
    )
  
  #melt 
  # goal RIT values
  stage_2a <- reshape2::melt(
    data = stage_1a,
    id.vars = names(stage_1a)[1:4]
  )
  # goal names
  stage_2b <- reshape2::melt(
    data = stage_1b,
    id.vars = names(stage_1b)[1:4]
  )
    
  # combine into one df
  stage_3 <- stage_2a
  stage_3$goal_name <- stage_2b$value
  stage_3$goal_name <- ifelse(stage_3$goal_name == '', NA, stage_3$goal_name)
  
  #drop NA
  stage_3 <- stage_3 %>%
    dplyr::filter(
      !is.na(goal_name)
    ) %>%
    dplyr::mutate(goal_name_formatted = stringr::str_wrap(goal_name,
                                                          width = 15))
  
  p <- ggplot(
    data = stage_3,
    aes(
      x = 0,
      y = value
    )
  ) +
  geom_boxplot(
    notch = TRUE
  ) +  
  stat_summary(
   aes(
     label = round(..y..,1)
   ),
   fun.y = mean,
   geom = 'text',
   size = 5
  ) +
  facet_grid(.~goal_name_formatted)  +
  labs(
    x = ' ', y = 'RIT Score'
  ) +
  theme_minimal() +  
  theme(
    panel.background = element_blank(),
    plot.background = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.title.y = element_blank(),
    axis.text.x = element_blank(),
    panel.spacing = grid::unit(0, "null"),
    plot.margin = margin(0, 0, 0, 0),
    axis.ticks = element_blank(),
    strip.text = element_text(size = 10)
  ) +
  theme(legend.position = "none")

  return(p)
}