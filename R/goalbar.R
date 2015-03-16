#' @title goal_bar
#' 
#' @description a simple bar chart that shows the percentage of a cohort at different goal
#' states (met / didn't meet)
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
#' @param goal_labels what labels to show for each goal category.  must be in order from 
#' highest to lowest.
#' @param goal_colors what colors to show for each goal category 
#' @param inprogress_prorater default is NA.  if set to a decimal value, what percent of the goal
#' is considered ontrack?
#' @param complete_obsv if TRUE, limit only to students who have BOTH a start
#' and end score. default is FALSE.
#' 
#' @export

goalbar <- function(
  mapvizieR_obj, 
  studentids, 
  measurementscale,
  start_fws,
  start_academic_year,
  end_fws,
  end_academic_year,
  goal_labels = c(accel_growth = 'Made Accel Growth', typ_growth = 'Made Typ Growth', 
    positive_but_not_typ = 'Below Typ Growth', negative_growth = 'Negative Growth', 
    no_start = sprintf('Untested: %s', start_fws), no_end = sprintf('Untested: %s', end_fws)
  ),
  goal_colors = c('#CC00FFFF', '#0066FFFF', '#CCFF00FF', '#FF0000FF', '#FFFFFF', '#F0FFFF'),
  inprogress_prorater = NA,
  complete_obsv = FALSE
) {
 
  #1| DATA PROCESSING

  #data validation and unpack
  mv_opening_checks(mapvizieR_obj, studentids, 1)
  
  #unpack the mapvizieR object and limit to desired students
  roster <- mapvizieR_obj[['roster']]
  growth_df <- mv_limit_growth(mapvizieR_obj, studentids, measurementscale)

  #limit to desired terms
  g <- growth_df %>%
    dplyr::filter(
      start_map_year_academic == start_academic_year,
      start_fallwinterspring == start_fws,
      end_map_year_academic == end_academic_year,
      end_fallwinterspring == end_fws
    )

  #limit to complete observations, if flag set
  if (complete_obsv == TRUE) {
    g <- g %>%
      dplyr::filter(
        complete_obsv == TRUE  
      )
  }

  #what to do if in-progress
  if (!is.na(inprogress_prorater)) {
      
  }
  
  #2| TAG ROWS
  g$goal_status <- NA
  #procedural
  g$goal_status <- ifelse(
    test = is.na(g$start_testritscore),
    yes = goal_labels[['no_start']],
    no = g$goal_status
  )
  
  g$goal_status <- ifelse(
    test = is.na(g$start_testritscore),
    yes = goal_labels[['no_end']],
    no = g$goal_status
  )
  
  #process categories in order from lowest to highest
  g$goal_status <- ifelse(
    test = g$rit_growth < 0,
    yes = goal_labels[['negative_growth']],
    no = g$goal_status
  )
  
  g$goal_status <- ifelse(
    test = g$rit_growth >= 0 & !g$met_typical_growth,
    yes = goal_labels[['positive_but_not_typ']],
    no = g$goal_status
  )
  
  #typ growth
  g$goal_status <- ifelse(
    test = g$met_typical_growth, 
    yes = goal_labels[['typ_growth']],
    no = g$goal_status
  )
  
  #accel growth
  g$goal_status <- ifelse(
    test = g$met_accel_growth, 
    yes = goal_labels[['accel_growth']],
    no = g$goal_status
  )
    
  g$status_ordered <- ordered(
    g$goal_status, levels = goal_labels
  )
    
  #make a data frame to look up statuses to colors
  temp_df <- data.frame(
    goal_status = goal_labels,
    goal_color = goal_colors
  )
  temp_df$goal_code <- rownames(temp_df)
  
  g_plot <- dplyr::left_join(x = g, y = temp_df, by = "goal_status")
  
  #should match the number of rows of the limited growth df
  if(nrow(g) != nrow(g_plot)) {
    warning(
      sprintf(paste0("the data frame used to make the plot was not able to ", 
        "categorize %f rows.  inspect the growth data frame of your mapvizieR ",
        "object for potential issues."), nrow(g) - nrow(g_plot))
    )
  }
  
  #3| REDUCE, SUMMARIZE
  g_sum <- g_plot %>%
    dplyr::group_by(goal_status, goal_color, status_ordered) %>%
    summarize(
      count = n(),
      label_disp = paste0('(', round(count / nrow(g_plot) * 100, 0), '%)')
    ) %>%
    #this was tricky!
    as.data.frame %>%
    mutate(
      label_pos = order_by(status_ordered, cumsum(count)),
      label_pos = label_pos - (0.5 * count)
    ) %>%
    arrange(status_ordered)
  
  g_sum
  
    
  #4| MAKE PLOT MAKE PLOT
  p <- ggplot(
    data = g_sum
   ,aes(
      x = 1
     ,y = count
     ,fill = goal_color
    )  
  ) + 
  geom_bar(stat="identity") +
  geom_text(
    aes(
     y = label_pos
    ,label = paste(goal_status, label_disp)
    )
   ,angle = 35
  ) + 
  coord_flip() +
  theme(
     axis.line=element_blank()
    ,axis.text=element_blank()
    ,axis.ticks=element_blank()
    ,axis.title=element_blank()
    ,legend.position="none"
    ,panel.background=element_blank()
    ,panel.border=element_blank()
    ,panel.grid.major=element_blank()
    ,panel.grid.minor=element_blank()
    ,plot.background=element_blank()
  ) +
  scale_fill_identity() 

  p

}