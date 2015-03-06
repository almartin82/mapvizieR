#' @title RIT distribution change (affectionately titled 'Galloping Elephants')
#'
#' @description
#' \code{galloping_elephants} returns ggplot density distributions that show change
#'  in RIT over time
#'
#' @param mapvizieR_obj a conforming mapvizieR object, which contains a cdf and a roster.
#' @param studentids which students to display?
#' @param measurementscale target subject
#' @param first_and_spring_only show all terms, or only entry & spring?  default is TRUE.
#' @param detail_academic_year don't mask any data for this academic year
#' @param entry_grade_seasons which grade_level_seasons are entry grades?
#' 
#' @return a ggplot object.
#' 
#' @export


galloping_elephants <- function (
  mapvizieR_obj,
  studentids,
  measurementscale,
  first_and_spring_only=TRUE,
  detail_academic_year=2014,
  entry_grade_seasons=c(-0.8, 4.2)
) {
  #data validation
  mv_opening_checks(mapvizieR_obj, studentids, 1)

  #unpack the mapvizieR object and limit to desired students
  this_cdf <- mv_limit_cdf(mapvizieR_obj, studentids, measurementscale)
  
  #only valid seasons
  munge <- valid_grade_seasons(this_cdf, first_and_spring_only, 
    entry_grade_seasons, detail_academic_year)

  #now group by grade level season and only return groups where n > 2
  #b/c geom_density will error on 2 data points.
  term_counts <- munge %>%
    dplyr::group_by(grade_season_label) %>%
    dplyr::summarize(
      count=n()  
    ) %>%
    dplyr::filter(
      count > 2
    ) 
  
  #filter the cdf by the valid terms above
  munge <- munge %>%
    dplyr::filter(
      grade_season_label %in% term_counts$grade_season_label
    ) %>%
    dplyr::mutate(
      grade_season_label=droplevels(grade_season_label)
    )    
  
  #a dummy plot, just to get heights of the density graphs
  dummy <- ggplot(
    data = munge
   ,aes(
      x = testritscore
     ,group = grade_season_label
    )
  ) + 
  geom_density()
  points <- ggplot_build(dummy)
  
  #just get the data
  density_raw <- points$data[[1]]
  #extract the max per group
  max_points <- density_raw %>%
    dplyr::group_by(group) %>%
    dplyr::summarize(
      y=max(y, na.rm=TRUE)  
    )

  #join a DF with extracted data & max values - this tags all the max rows in the df
  full_max <- dplyr::inner_join(density_raw, max_points, by=c("y", "group"))
  
  #cbind in the factor names (ie the group names)
  full_max <- cbind(full_max, grade_labels=term_counts$grade_season_label)
  
  #make and return the plot
  p <- ggplot(
    data=munge
   ,aes(
      x = testritscore
     ,group = grade_season_label
     ,fill = grade_season_label
     ,alpha = grade_season_label
    )
  ) + 
# do we want to play with the line top of the geom_density distros?
#   geom_line(
#     stat="density"
#    ,size=3
#   ) +
  geom_point(
    aes(
      y = 0
    )
   ,alpha = 0
  ) +
  geom_density(
    adjust = 1
   ,size = 0.5
   ,color = 'black'
  ) +
  scale_fill_brewer(
    #type = 'div', palette = 'RdYlBu'
    type = 'seq', palette = 'Blues'
    #start = 0.2, end = 0.8, na.value = "red"
  ) + 
  scale_alpha_discrete(range = c(0.5, 0.85)) +
  theme_bw() +
  theme(
    #zero out formats
    panel.background = element_blank()
   ,plot.background = element_blank()
   ,panel.grid.major = element_blank()
   ,panel.grid.minor = element_blank()
   ,legend.position = 'none'
    
   ,axis.text.y = element_blank()
   ,axis.ticks.y = element_blank()
   ,plot.margin = rep(unit(0,"null"),4)
   ,axis.title.x = element_blank()
   ,axis.title.y = element_blank()
  ) 

  #annotate
  p <- p + annotate(
    geom = 'text'
   ,x = full_max$x
   ,y = full_max$y
   ,label = full_max$grade_labels
   ,size = 7
  )
  
  plot_min <- round_to_any(
    x = min(munge$testritscore, na.rm=TRUE)
   ,accuracy = 10
   ,f = floor
  )  
  plot_max <- round_to_any(
    x = max(munge$testritscore, na.rm=TRUE)
   ,accuracy = 10
   ,f = ceiling
  )
  
  #limits and breaks
  p <- p + scale_x_continuous(
    limits=c(plot_min, plot_max)
   ,breaks=seq(plot_min, plot_max, 10)
  )
  
  p  
}
