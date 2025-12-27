#' @title Becca Vichniac's Quartile (Floating Bar) Chart 
#'
#' @description
#' \code{becca_plot} returns a ggplot object binned quaritle performonce
#'
#' @details 
#' This function builds and prints a bar graph with 4 bins per bar show MAP data
#' binned by quartile (National Percentile Rank).  Bars are centered at 50th percentile 
#' horizonatally
#' 
#' @param mapvizieR_obj mapvizieR object
#' @param studentids target students
#' @param measurementscale target subject
#' @param first_and_spring_only show all terms, or only entry & spring?  default is TRUE.
#' @param entry_grade_seasons which grade_level_seasons are entry grades?
#' @param detail_academic_year don't mask any data for this academic year
#' @param small_n_cutoff drop a grade_level_season if less than x% of the max? 
#' (useful when dealing with weird cohort histories)
#' @param color_scheme color scheme for the stacked bars.  options are 'KIPP Report Card', 
#' 'Sequential Blues', or a vector of 4 colors.
#' @param quartile_type c('KIPP Report Card', 'NYS') KIPP Report Card = traditional quartiles.  NYS = predicted
#' perf level on NYS test.
#' 
#' @return prints a ggplot object
#' 
#' @export

becca_plot <- function(
  mapvizieR_obj, 
  studentids, 
  measurementscale, 
  first_and_spring_only = TRUE, 
  entry_grade_seasons = c(-0.8, 4.2), 
  detail_academic_year = 2014, 
  small_n_cutoff = .5,
  color_scheme = 'KIPP Report Card',
  quartile_type = 'kipp_quartile'
) {

  #data validation
  mv_opening_checks(mapvizieR_obj, studentids, 1)

  valid_color_schemes <- c('KIPP Report Card', 'NYS')
  if (!(any(color_scheme %in% valid_color_schemes | length(color_scheme) == 4L))) {
    cli::cli_abort(paste0("color scheme should be either one of: ",
             paste(valid_color_schemes, collapse = ', '),
             " or a length 4 vector of colors"))
  }

  #TRANSFORMATION 1 - DATA PROCESSING
  #unpack the mapvizieR object and limit to desired students
  this_cdf <- mv_limit_cdf(mapvizieR_obj, studentids, measurementscale)
    
  #detect entry grade seasons
  if (entry_grade_seasons[1] == 'detect') {
    entry_grade_seasons <- min_term_filter(this_cdf, small_n_cutoff) %>% 
      dplyr::ungroup() %>%
      dplyr::select(grade_level_season) %>%
      min()
  }
  
  #only valid seasons
  munge <- valid_grade_seasons(this_cdf, first_and_spring_only, 
    entry_grade_seasons, detail_academic_year)
  
  #filter out small N 
  munge <- min_term_filter(munge, small_n_cutoff)
 
  #tag with quartiles
  munge$quartile <- do.call(quartile_type, list(munge$testpercentile))

  #TRANSFORMATION 2 - BIN COUNTS FOR BECCA PLOT
  #calculate group level averages.  Our final data set should have
  #SUBJECT    GRADE_LEVEL_SEASON     QUARTILE      PCT
  
  term_totals <- munge %>%
    dplyr::ungroup() %>%
    dplyr::select(
      measurementscale, grade_level_season, quartile
    ) %>%
    #first group by term
    dplyr::group_by(
      measurementscale, grade_level_season  
    ) %>%
    dplyr::summarize(
      n_total = dplyr::n()
    ) %>%
    as.data.frame()
  
  quartile_totals <- munge %>%
    #then group by quartile
    dplyr::group_by(
      measurementscale, grade_level_season, quartile
    ) %>%
    #include at grade level flag
    dplyr::summarize(
      n_quartile = dplyr::n()
    ) %>%
    dplyr::mutate(
      at_grade_level_dummy = ifelse(quartile %in% c(3, 4), 'Yes', 'No'),
      order = quartile_order(as.numeric(quartile))
    )
          
  
  prepped <- dplyr::left_join(
      x = quartile_totals, 
      y = term_totals[, c(2,3)],
      by = "grade_level_season"
    ) %>%
    dplyr::mutate(
      pct = n_quartile /  n_total * 100
    ) %>%
    as.data.frame()
  
  #TRANSFORMATION - TWO dfs FOR CHART
  #super helpful advice from: http://stackoverflow.com/a/13734448/561698
  npr_above <- prepped[prepped$at_grade_level_dummy == 'Yes', ]
  npr_below <- prepped[prepped$at_grade_level_dummy == 'No', ]

  #flip the sign
  npr_below$pct <- npr_below$pct * -1
  
  #midpoints for labels
  npr_above <- npr_above %>%
    dplyr::group_by(grade_level_season) %>%
    dplyr::mutate(
      cumsum = dplyr::with_order(order_by = order, fun = cumsum, x = pct),
      midpoint = cumsum - (0.5 * pct)
    )

  npr_below <- npr_below %>%
    dplyr::group_by(grade_level_season) %>%
    dplyr::arrange(order) %>%
    dplyr::mutate(
      cumsum = dplyr::with_order(order_by = order, fun = cumsum, x = pct),
      midpoint = cumsum - (0.5 * pct)
    )

  x_breaks <- sort(unique(prepped$grade_level_season))
  x_labels <- unlist(lapply(x_breaks, fall_spring_me))

  #MAKE THE PLOT
  p <- ggplot() +
    #top half of NPR plots
    geom_bar(
      data = npr_above,
      aes(
        x = grade_level_season,
        y = pct,
        fill = factor(quartile, levels = c(4, 3))
      ),
      stat = "identity"
    ) +
  #bottom half of NPR plots, supressing silly warning that happens when you have negative ys
    geom_bar(
      data = npr_below,
      aes(
        x = grade_level_season,
        y = pct,
        fill = factor(quartile)
      ),
      stat = "identity"
    ) 
  
  #labels above
  p <- p +
    geom_text(
      data = npr_above,
      aes(
        x = grade_level_season,
        y = midpoint,
        label = round(pct,0)
      ),
      size = 4
    ) +
    #labels below
    geom_text(
      data = npr_below,
      aes(
        x = grade_level_season,
        y = midpoint,
        label = abs(round(pct, 0))
      ),
      size = 4
    ) +
    #axis labels
    labs(
      x = 'Grade Level',
      y = 'Percentage of Cohort'
    ) +
    theme_bw() +
    #zero out cetain formatting
    theme(      
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      panel.border = element_blank(),
      axis.ticks.y = element_blank(),
      axis.text.y = element_blank(),
      axis.title.x = element_text(size = rel(0.9)),
      plot.margin = margin(0, 0, 0, 0)
    ) +
    scale_x_continuous(
      breaks = x_breaks,
      labels = x_labels
    ) +
    coord_cartesian(
      xlim = c(min(x_breaks) - 0.25, max(x_breaks) + 0.25)  
    )

  legend_labels = c('1st', '2nd', '3rd', '4th')
  
  #color style?
  if ('KIPP Report Card' %in% color_scheme) {
    p <- p + scale_fill_manual(
      values = kipp_4col, labels = legend_labels, name = 'Quartiles'
    )
  } else if ('NYS' %in% color_scheme) {
    p <- p + scale_fill_manual(
      values = kipp_4col, labels = c('1', '2', '3', '4'), name = 'Perf Level'
    )
  } else {
    p <- p + scale_fill_manual(
      values = color_scheme, labels = legend_labels, name = 'Quartiles'
    )
  }
  
  p <- p + guides(fill = guide_legend(reverse = TRUE))
  
  # return
  p 
}
