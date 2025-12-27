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

galloping_elephants <- function(mapvizieR_obj,
                                 studentids,
                                 measurementscale,
                                 first_and_spring_only = TRUE,
                                 detail_academic_year = 2014,
                                 entry_grade_seasons = c(-0.8, 4.2)) {
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
    dplyr::summarize(count = dplyr::n()) %>%
    dplyr::filter(count > 2)
  
  #need SOME season with 2 or more rows
  ensure_rows_in_df(term_counts)
  
  #filter the cdf by the valid terms above
  munge <- munge %>%
    dplyr::ungroup() %>%
    dplyr::filter(grade_season_label %in% term_counts$grade_season_label) %>%
    dplyr::mutate(grade_season_label = droplevels(grade_season_label))
  
  #a dummy plot, just to get heights of the density graphs
  dummy <- ggplot(
    data = munge,
    aes(
      x = testritscore,
      group = grade_season_label,
      label = grade_season_label
    )
  ) +
  geom_density()
  
  points <- ggplot_build(dummy)
  
  #just get the data
  density_raw <- points$data[[1]]
  
  #extract the max per group
  max_points <- density_raw %>%
    dplyr::group_by(group, label) %>%
    dplyr::summarize(y = max(y, na.rm = TRUE))
  
  #join a DF with extracted data & max values - this tags all the max rows in the df
  full_max <-
    dplyr::inner_join(max_points, density_raw, by = c("y", "group", "label"))
  
  #ahhhhhhhhhhhhhhhhhhhhhhhhhh
  #under certain circumstances, due to rounding, the maximum value is NOT guaranteed to be unique
  #ensure only one point is returned by grouping and calling max.
  full_max <- full_max %>%
    dplyr::group_by(group, label) %>%
    dplyr::summarize(
      x = max(x, na.rm = TRUE),
      y = max(y, na.rm = TRUE)
    )
  
  #cbind in the factor names (ie the group names)
  full_max <- dplyr::bind_cols(full_max, data.frame(grade_labels = term_counts$grade_season_label, stringsAsFactors = FALSE))
  
  #make and return the plot
  p <- ggplot(
    data = munge,
    aes(
      x = testritscore,
      group = grade_season_label,
      fill = grade_season_label,
      alpha = grade_season_label
    )
  ) +
    geom_point(aes(y = 0),
               alpha = 0) +
    geom_density(adjust = 1,
                 linewidth = 0.5,
                 color = 'black') +
    scale_fill_brewer(type = 'seq', palette = 'Blues') +
    scale_alpha_discrete(range = c(0.5, 0.85)) +
    theme_bw() +
    theme(
      #zero out formats
      panel.background = element_blank(),
      panel.border = element_blank(),
      plot.background = element_blank(),
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      legend.position = 'none',
      axis.text.y = element_blank(),
      axis.ticks.y = element_blank(),
      plot.margin = margin(0, 0, 0, 0),
      axis.title.x = element_blank(),
      axis.title.y = element_blank()
    )
  
  #annotate
  p <- p + annotate(
    geom = 'text',
    x = full_max$x,
    y = full_max$y,
    label = full_max$grade_labels,
    size = 7
  )
  
  plot_min <- mapvizieR::round_to_any(
    x = min(munge$testritscore, na.rm = TRUE),
    accuracy = 10,
    f = floor
  )
  plot_max <- mapvizieR::round_to_any(
    x = max(munge$testritscore, na.rm = TRUE),
    accuracy = 10,
    f = ceiling
  )
  
  #limits and breaks
  p <- p + scale_x_continuous(limits = c(plot_min, plot_max),
                              breaks = seq(plot_min, plot_max, 10))
  
  p
}
