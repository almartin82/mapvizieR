#' @title goal strand boxes
#'
#' @param mapvizieR_obj mapvizieR object
#' @param studentids target students
#' @param measurementscale_in target subject
#' @param fws season
#' @param academic_year academic year
#' 
#' @return prints a ggplot object
#' 
#' @export

strand_boxes <- function(
  mapvizieR_obj,
  studentids,
  measurementscale_in,
  fws,
  academic_year
) {
  #data validation and unpack
  mv_opening_checks(mapvizieR_obj, studentids, 1)

  #unpack the mapvizieR object and limit to desired students
  goal_df <- mapvizieR_obj[['cdf']] %>%
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
    )
  
  #plot variables
  e <- new.env()
  e$y_center <- min(stage_3$value, na.rm = TRUE) + 0.5 * (max(stage_3$value, na.rm = TRUE) - min(stage_3$value, na.rm = TRUE)) 
  e$goal_names <- attributes(factor(stage_3$goal_name))$levels
  
  n <- 25
  more_n <- nchar(e$goal_names) > n
  smart_breaks <- ifelse(more_n, '-\n', '')
  
  e$goal_names_format <- paste(
    substr(e$goal_names, start = 1, stop = n), smart_breaks,
    substr(e$goal_names, start = n + 1, stop = 100), sep = ''
  )
  
  p <- ggplot(
    data = stage_3,
    aes(
      x = factor(goal_name),
      y = value,
      fill = factor(goal_name)
    ),
    environment = e
  ) +
  #empty
  geom_jitter(
    alpha = 0
  ) + 
  annotate(
    "text",
    x = seq(1, length(e$goal_names_format)),
    y = rep(e$y_center, length(e$goal_names_format)),
    label = e$goal_names_format,
    angle = 90,
    size = 7,
    color = 'gray60',
    alpha = .9
  ) +
  geom_boxplot(
    alpha = 0.6
  ) +
  geom_jitter(
    position = position_jitter(width = .15),
    color = 'gray85',
    alpha = 0.6,
    shape = 1
  ) + 
  stat_summary(
   aes(
     label = round(..y..,1)
   ),
   fun.y = mean,
   geom = 'text',
   size = 7
  ) +
  labs(
    x = 'Goal Name', y = 'RIT Score'
  ) +
  theme(
    panel.background = element_blank(),
    plot.background = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.title.y = element_blank(),
    axis.text.x = element_blank(),
    panel.margin = unit(0, "null"),
    plot.margin = rep(unit(0, "null"), 4),
    axis.ticks.margin = unit(0, "null")
  ) +
  theme(legend.position = "none")

  return(p)
}