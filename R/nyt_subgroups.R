#' @title nyt_subgroups
#' 
#' @description the times did a nice job capturing change in the population vs
#' change in subgroups: http://nyti.ms/1tQrOIl 
#' let's do the same thing for change in RIT score.
#' 
#' @param mapvizieR_obj mapvizieR object
#' @param studentids target students
#' @param measurementscale target subject
#' @param subgroup_cols what subgroups in mapvizier roster do you want to cut by?  default
#' is starting_quartile
#' @param pretty_names nicely formatted names for the column cuts used above.
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
  subgroup_cols = c('starting_quartile'),
  pretty_names = c('Starting Quartile'),
  start_fws,
  start_academic_year,
  end_fws,
  end_academic_year,
  complete_obsv = FALSE
) {
  
  #1| DATA PROCESSING

  #data validation and unpack
  mv_opening_checks(mapvizieR_obj, studentids, 1)
  assert_that(length(subgroup_cols) == length(pretty_names))

  #unpack the mapvizieR object and limit to desired students
  roster <- mapvizieR_obj[['roster']]
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
  
  #put starting quartile on the roster and rename
  roster <- dplyr::left_join(
    x = roster,
    y = this_growth[ ,c('studentid', 'start_testquartile')],
    by = 'studentid'
  )
  roster$start_testquartile <- ifelse(
    !is.na(roster$start_testquartile),
    paste('Quartile', roster$start_testquartile),
    NA
  )
  
  names(roster)[names(roster)=='start_testquartile'] <- 'starting_quartile'
  
  #require that all subgroups match names of the roster.
  roster %>% 
    ensure_that(
      all(subgroup_cols %in% names(roster)) ~ "subgroup_cols must match column names in your mapvizieR roster."
    )
  
  #complete observations?
  if (complete_obsv == TRUE) {
    this_growth <- this_growth %>%
      dplyr::filter(
        complete_obsv == TRUE  
      )
  }
  
  #2| INTERNAL FUNCTIONS
  group_summary <- function(grouped_df, subgroup) {
    df <- grouped_df %>%
    summarize(
      start_rit = mean(start_testritscore, na.rm=TRUE),
      end_rit = mean(end_testritscore, na.rm=TRUE),
      rit_change = mean(rit_growth, na.rm=TRUE),
      start_npr = mean(start_consistent_percentile, na.rm=TRUE),
      end_npr = mean(end_consistent_percentile, na.rm=TRUE),
      npr_change = mean(start_consistent_percentile - end_consistent_percentile, na.rm=TRUE)
    ) %>%
    as.data.frame
    
    names(df)[names(df)==subgroup] <- 'facet_me'
    
    df
  }
    
  
  facet_one_subgroup <- function(df, subgroup) {
    #make
    p <- ggplot(
      data=df
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
      facet_me ~ . 
    ) +
    theme_bw() +
    theme(
      axis.title.y = element_blank(),
      axis.text.y = element_blank(),
      axis.ticks.y = element_blank(),
      panel.grid.major = element_blank()
    ) 
  
    #title
    p_title <- grob_justifier(
      textGrob(subgroup, gp=gpar(fontsize=24, fontface = 'bold')), 
      "center", "center"
    )
    
    #arrange and return
    arrangeGrob(
      p_title, p,
      nrow = 2, heights = c(1, 7)
    )    
  }
  
  #3| DATA CUTS
  #all students
  this_growth$all_students <- 'All Students'
  total_change <- group_summary(dplyr::group_by(this_growth, all_students), 'all_students')
  p_all <- facet_one_subgroup(total_change, 'All Students')
  
  #iterate over subgroups
  plot_list <- list()
  plot_list[[1]] <- p_all
  counter <- 2
  
  for (i in 1:length(subgroup_cols)) {
    subgroup <- subgroup_cols[i]
    
    #join roster and data
    minimal_roster <- roster[, c('studentid', subgroup)]
    combined_df <- dplyr::inner_join(
      x = this_growth,
      y = minimal_roster,
      by = 'studentid'
    )
    
    #now group by subgroup and summarize
    grouped_df <- dplyr::group_by_(combined_df, subgroup)
    this_summary <- group_summary(grouped_df, subgroup)
    plot_list[[counter]] <- facet_one_subgroup(this_summary, pretty_names[i])    
    
    counter <- counter + 1
  }  
  
  do.call(
    what="arrangeGrob",
    args=plot_list
  )
}

