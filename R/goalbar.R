#' @title goal_bar
#'
#' @description a simple bar chart that shows the percentage of a cohort at different goal
#' states (met / didn't meet)
#'
#' @param mapvizieR_obj mapvizieR object
#' @param studentids target students
#' @param measurementscale target subject
#' @param start_fws starting season
#' @param start_academic_year starting academic year
#' @param end_fws ending season
#' @param end_academic_year ending academic year
#' @param goal_labels what labels to show for each goal category.  must be in order from
#' highest to lowest.
#' @param goal_colors what colors to show for each goal category
#' @param ontrack_prorater default is NA.  if set to a decimal value, what percent of the goal
#' is considered ontrack?
#' @param ontrack_fws season to use for determining ontrack status
#' @param ontrack_academic_year year to use for determining ontrack status
#' @param ontrack_labels what labels to use for the 3 ontrack statuses
#' @param ontrack_colors what colors to use for the 3 ontrack colors
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
    no_start = sprintf('Untested: %s %s', start_fws, start_academic_year),
    no_end = sprintf('Untested: %s %s', end_fws, end_academic_year)
  ),
  goal_colors = c('#CC00FFFF', '#0066FFFF', '#CCFF00FF', '#FF0000FF', '#FFFFFF', '#F0FFFF'),
  ontrack_prorater = NA,
  ontrack_fws = NA,
  ontrack_academic_year = NA,
  ontrack_labels = c(ontrack_accel = 'On Track for Accel Growth',
    ontrack_typ = 'On Track for Typ Growth', offtrack_typ = 'Off Track for Typ Growth'
  ),
  ontrack_colors = c('#CC00FFFF', '#0066FFFF', '#CCFF00FF'),
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
        complete_obsv == TRUE,
        !is.na(typical_growth)
      )
  }

  #if no students have growth norms, throw an error.
  ensure_nonzero_students_with_norms(g)


  #2| TAG ROWS
  g$goal_status <- NA
  #procedural
  g$goal_status <- ifelse(
    test = is.na(g$start_testritscore),
    yes = goal_labels[['no_start']],
    no = g$goal_status
  )

  g$goal_status <- ifelse(
    test = is.na(g$end_testritscore),
    yes = goal_labels[['no_end']],
    no = g$goal_status
  )

  #process categories in order from lowest to highest
  g$goal_status <- ifelse(
    test = g$rit_growth < 0 & !is.na(g$rit_growth),
    yes = goal_labels[['negative_growth']],
    no = g$goal_status
  )

  g$goal_status <- ifelse(
    test = g$rit_growth >= 0 & !g$met_typical_growth & !is.na(g$rit_growth),
    yes = goal_labels[['positive_but_not_typ']],
    no = g$goal_status
  )

  #typ growth
  g$goal_status <- ifelse(
    test = g$met_typical_growth & !is.na(g$rit_growth),
    yes = goal_labels[['typ_growth']],
    no = g$goal_status
  )

  #accel growth
  g$goal_status <- ifelse(
    test = g$met_accel_growth & !is.na(g$rit_growth),
    yes = goal_labels[['accel_growth']],
    no = g$goal_status
  )

  #make a data frame to look up statuses to colors
  temp_df <- data.frame(
    goal_status = goal_labels,
    goal_color = goal_colors,
    stringsAsFactors = FALSE
  )
  temp_df$goal_code <- rownames(temp_df)

  #what to do if in-progress
  if (!is.na(ontrack_prorater)) {
    ontrack <- mv_limit_cdf(mapvizieR_obj, studentids, measurementscale)
    ontrack <- ontrack %>%
      dplyr::filter(
        map_year_academic == ontrack_academic_year,
        fallwinterspring == ontrack_fws
      )

    ontrack <- ontrack[, c('studentid', 'testritscore')]
    names(ontrack)[2] <- 'ontrack_rit'
    g <- dplyr::left_join(
      x = g,
      y = ontrack,
      by = 'studentid'
    )

    #highest to lowest
    #on track accel
    g$goal_status <- ifelse(
      test = (g$ontrack_rit - g$start_testritscore) * ontrack_prorater >= g$accel_growth &
        !is.na(g$ontrack_rit),
      yes = ontrack_labels[['ontrack_accel']],
      no = g$goal_status
    )

    #on track typ
    g$goal_status <- ifelse(
      test = (g$ontrack_rit - g$start_testritscore) * ontrack_prorater >= g$reported_growth &
        !is.na(g$ontrack_rit),
      yes = ontrack_labels[['ontrack_typ']],
      no = g$goal_status
    )

    #on track typ
    g$goal_status <- ifelse(
      test = (g$ontrack_rit - g$start_testritscore) * ontrack_prorater < g$reported_growth &
        !is.na(g$ontrack_rit),
      yes = ontrack_labels[['offtrack_typ']],
      no = g$goal_status
    )

    #extend status df
    ontrack_df <- data.frame(
      goal_status = ontrack_labels,
      goal_color = ontrack_colors,
      stringsAsFactors = FALSE
    )
    ontrack_df$goal_code <- rownames(ontrack_df)

    temp_df <- rbind(temp_df, ontrack_df)
  }

  #turn status into ordered factor
  g$status_ordered <- ordered(
    g$goal_status, levels = temp_df$goal_status
  )

  g_plot <- dplyr::inner_join(x = g, y = temp_df, by = "goal_status")

  #should match the number of rows of the limited growth df
  if(nrow(g) != nrow(g_plot)) {
    warning(
      sprintf(paste0("the data frame used to make the plot was not able to ",
        "categorize %i rows.  inspect the growth data frame of your mapvizieR ",
        "object for potential issues.  consider setting complete_obsv = TRUE"),
        round(nrow(g) - nrow(g_plot), 0)
      )
    )
  }

  #3| REDUCE, SUMMARIZE
  g_sum <- g_plot %>%
    dplyr::group_by(goal_status, goal_color, status_ordered) %>%
    dplyr::summarize(
      count = n(),
      label_disp = paste0('(', round(count / nrow(g_plot) * 100, 0), '%)')
    ) %>%
    #this was tricky!
    as.data.frame %>%
    dplyr::mutate(
      label_pos = dplyr::with_order(order_by = status_ordered, fun = cumsum, x = count),
      label_pos = label_pos - (0.5 * count)
    ) %>%
    dplyr::arrange(status_ordered)

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
  geom_bar(stat = "identity") +
  geom_text(
    aes(
     y = label_pos
    ,label = paste(goal_status, label_disp)
    )
   ,angle = 35
  ) +
  coord_flip() +
  theme(
     axis.line = element_blank()
    ,axis.text = element_blank()
    ,axis.ticks = element_blank()
    ,axis.title = element_blank()
    ,legend.position = "none"
    ,panel.background = element_blank()
    ,panel.border = element_blank()
    ,panel.grid.major = element_blank()
    ,panel.grid.minor = element_blank()
    ,plot.background = element_blank()
  ) +
  scale_fill_identity()

  p

}
