#' @title nyt_subgroups
#' 
#' @description the times did a nice job capturing change in the population vs
#' change in subgroups: http://nyti.ms/1tQrOIl 
#' let's do the same thing for change in RIT score.
#' 
#' @param mapvizieR_obj mapvizieR object
#' @param studentids target students
#' @param measurementscale target subject
#' @param start_fws starting season
#' @param start_academic_year starting academic year
#' @param end_fws ending season
#' @param end_academic_year ending academic year
#' @param complete_obsv if TRUE, limit only to students who have BOTH a start
#' and end score. default is FALSE.
#' 
#' @export

nyt_subgroups <- function(
  mapvizieR_obj, 
  studentids, 
  measurementscale,
  start_fws,
  start_academic_year,
  end_fws,
  end_academic_year,
  complete_obsv = FALSE
) {
  #data validation and unpack
  mv_opening_checks(mapvizieR_obj, studentids, 1)

  #unpack the mapvizieR object and limit to desired students
  growth_df <- mv_limit_growth(mapvizieR_obj, studentids, measurementscale)

  #data processing
  #just desired terms
  this_growth <- growth_df %>%
    dplyr::filter(
      start_map_year_academic == start_academic_year,
      start_fallwinterspring == start_fws,
      end_map_year_academic == end_academic_year,
      end_fallwinterspring == end_fws
    )
  
  #complete observations?
  if (complete_obsv == TRUE) {
    this_growth <- this_growth %>%
      dplyr::filter(
        complete_obsv == TRUE  
      )
  }
  
  #data cuts
  #1. overall
  total_change <- this_growth %>%
    summarize(
      start_rit = mean(start_testritscore, na.rm=TRUE),
      end_rit = mean(end_testritscore, na.rm=TRUE),
      rit_change = mean(rit_growth, na.rm=TRUE)
    )
  total_change$grouping <- 'All Students'
  total_change$order <- 1
  
  #2. starting quartile
  starting_quartile <- this_growth %>%
    dplyr::group_by(
      start_testquartile      
    ) %>%
    summarize(
      start_rit = mean(start_testritscore, na.rm=TRUE),
      end_rit = mean(end_testritscore, na.rm=TRUE),
      rit_change = mean(rit_growth, na.rm=TRUE)        
    )
  
  starting_quartile[, 1] <- paste('Quartile', starting_quartile$start_testquartile)
  names(starting_quartile)[1] <- 'grouping'
  starting_quartile$order <- 2
  
  #by quartile
  #TODO: figure out how to get by starting quartile
  
  #bind all the cuts together.
  plot_df <- rbind(total_change, starting_quartile)

  #make plot
  p <- ggplot(
    data=plot_df
   ,aes(
      x = start_rit,
      xend = end_rit,
      y = 1,
      yend = 1
    )
  ) +
  geom_segment(
    arrow = arrow(length = unit(0.3,"cm"))
  ) +
  #start rit
  geom_text(
    aes(
      x = start_rit,
      y = 1,
      label = round(start_rit, 1)
    ),
    inherit.aes = FALSE,
    vjust = 1,
    hjust = 0.5
  ) +
  #end rit
  geom_text(
    aes(
      x = end_rit,
      y = 1,
      label = round(end_rit, 1)
    ),
    inherit.aes = FALSE,
    vjust = 1,
    hjust = 0.5
  ) +    
  facet_grid(
    grouping ~ . 
  ) +
  theme_bw() +
  theme(
    axis.title.y=element_blank(),
    axis.text.y=element_blank(),
    axis.ticks.y=element_blank()
  )
    
  #return
  p
  
}

