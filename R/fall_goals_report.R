#' Fall Goals Report
#'
#' @param mapvizieR_obj a valid mapvizieR_object
#' @param studentids a vector of studentids to run
#' @param measurementscale desired subject
#' @param context what school/grade/class/etc grouping is represented?
#' @param start_fws character, starting season for school growth norms
#' @param start_year_offset 0 if start season is same, -1 if start is prior year.
#' @param end_fws ending season
#' @param end_academic_year ending academic year
#' @param entry_grade_seasons for becca plot.  default is c(-0.8, 4.2)
#' @param exclude_prior_year_holdover if, for instance, this year's 3rd grade
#' includes students who were in the 3rd grade last year,  drop their records from
#' the data
#' @param detail_academic_year passed through to various plots
#' @param goal_cgp what target CGP should be used for goals?
#' @param school_type c('ES', 'MS')
#' @param localization controls goals and goal logic for report.  
#' See localization.R for more details
#' 
#' @return a multipage report, represented as a list of grobs.
#' @export

fall_goals_report <- function(
  mapvizieR_obj, 
  studentids, 
  measurementscale, 
  context,
  start_fws = 'Spring',
  start_year_offset = -1,
  end_fws = 'Spring',
  end_academic_year = 2015,
  entry_grade_seasons = c(-0.8, 4.2),
  exclude_prior_year_holdover = TRUE,
  detail_academic_year = 9999,
  goal_cgp = 80,
  school_type = 'MS',
  localization = localize('Newark')
) {
  
  #placeholder
  minimal = rectGrob(gp = gpar(col = "white"))
  
  report_list <- list()
  
  #1. Where have my students been?
  mapvizieR_obj$cdf <- impute_rit(
    mapvizieR_obj = mapvizieR_obj,
    studentids = studentids, 
    measurementscale = measurementscale
  )

  end_grade <- mapvizieR_obj$roster %>%
    dplyr::filter(
      studentid %in% studentids &
        map_year_academic == end_academic_year
    ) %>% 
    dplyr::select(
      grade
    ) %>%
    table() %>% sort() %>% names() %>% rev() %>% 
    magrittr::extract(1) %>% as.numeric()
  
  if (exclude_prior_year_holdover) {
    mapvizieR_obj$cdf <- mapvizieR_obj$cdf %>% dplyr::filter(
      grade < end_grade
    )
  }  
  
  p1_main <- fall_goals_report_p1(
    mapvizieR_obj, 
    studentids, 
    measurementscale, 
    context,
    start_fws,
    start_year_offset,
    end_fws,
    end_academic_year,
    entry_grade_seasons,
    exclude_prior_year_holdover,
    detail_academic_year,
    goal_cgp,
    school_type,
    localization
  )
  p1_top <- h_var('1. Where have my students been?', 20)
  p1 <- gridExtra::arrangeGrob(
    p1_top, p1_main, nrow = 2, heights = c(1, 17)
  )
  p1 <- report_footer(p1, context)
  
  report_list[[1]] <- p1

  #2. Where do they need to go?
  #in words
  goals_words <- fall_goals_data_table(
    mapvizieR_obj,
    studentids,
    measurementscale,
    start_fws,
    start_year_offset,
    end_fws,
    end_academic_year,
    end_grade,
    start_fws_prefer, 
    calc_for = goal_cgp,
    output = 'baseline',
    font_size = 34
  )
  goals_words_exp1 <- h_var(
    "Baseline RIT (measured in class average RIT)",
    gp = grid::gpar(fontsize = 16, fontface = "italic")
  )
  if (length(start_fws) > 1) {
    goals_words_exp2 <- h_var(
      sprintf(
        "Baseline RIT includes student %s score when available, %s when not.", 
        start_fws[1], start_fws[2]
      ),
      gp = grid::gpar(fontsize = 11, fontface = 'plain')
    )
  } else if (length(start_fws == 1)) {
    goals_words_exp2 <- h_var(
      sprintf("Baseline RIT includes only student %s scores.", start_fws), 
      gp = grid::gpar(fontsize = 11, fontface = 'plain')
    )
  }
  
  goals_words <- gridExtra::arrangeGrob(
    goals_words_exp1, goals_words, goals_words_exp2, nrow = 3, heights = c(1, 2.5, .5)
  )
  
  #distro
  expectations_df <- mapviz_cgp_targets(
    mapvizieR_obj,
    studentids,
    measurementscale,
    start_fws,
    start_year_offset,
    end_fws,
    end_academic_year,
    end_grade,
    start_fws_prefer, 
    calc_for = goal_cgp,
    returns = 'expectations'
  )
  
  goals_distro_exp <- h_var(
    "The NWEA school growth study shows \nhow much growth similar classes make.",
    gp = grid::gpar(fontsize = 16, fontface = "italic")
  )
  goals_distro_plot <- cohort_growth_expectations_plot(
    expectations_df = expectations_df,
    ref_lines = c(.01, .05, .2, .5, .8, .95, .99, goal_cgp / 100) %>% unique(),
    highlight = goal_cgp / 100
  )
  
  goals_distro <- gridExtra::arrangeGrob(
    goals_distro_exp, goals_distro_plot, nrow = 2, heights = c(1, 3)
  )
  
  #goals
  goals_target_exp <- h_var(
    paste0(
      "Our goal is for this cohort to grow \nin the top ", 
      sprintf("%s of cohorts nationally.", paste0(100 - goal_cgp, '%'))
    ),
    gp = grid::gpar(fontsize = 16, fontface = "italic")
  )
  goals_target <- fall_goals_data_table(
    mapvizieR_obj,
    studentids,
    measurementscale,
    start_fws,
    start_year_offset,
    end_fws,
    end_academic_year,
    end_grade,
    start_fws_prefer, 
    calc_for = goal_cgp,
    output = 'goals',
    font_size = 34
  )
  goals_target <- gridExtra::arrangeGrob(
    goals_target_exp, goals_target, minimal, nrow = 3, heights = c(1, 2.5, .5)
  )
  
  goals <- gridExtra::arrangeGrob(
    goals_words, goals_distro, goals_target, ncol = 3
  )
  
  #sim
  fall_goals_local_df = localization$fall_goals_data
  
  this_report <- fall_goals_local_df %>%
    dplyr::filter(
      report_measurementscale == measurementscale &
        report_schooltype == school_type
    )
  
  sim_header_l <- h_var(
    sprintf("Why is our growth goal at the %sth percentile?", goal_cgp),
    gp = grid::gpar(fontsize = 20, fontface = "bold.italic")
  )
  
  sim_header_r <- h_var(
    sprintf("What would CGP %s growth mean for this cohort?", goal_cgp),
    gp = grid::gpar(fontsize = 20, fontface = "bold.italic")
  )
  
  left_exp <- RGraphics::splitTextGrob(
    paste0(
      "The KIPP 2020 Goal calls for 50% of students to finish ",
      sprintf("%s school above the 75th ", this_report$verbose_schooltype),
      sprintf("percentile in %s. ", measurementscale),
      "That's roughly equivalent to a class average RIT ",
      sprintf("of %s by the end ", this_report$annotate_y),
      sprintf("of %s grade. ", this_report$annotate_x %>% toOrdinal::toOrdinal()),
      "The chart below demonstrates how we calibrated these goals, ",
      "showing how a cohort would grow, assuming our historical entering ",
      sprintf("%s RIT (%s) as a baseline, ", school_type, this_report$sim_start),
      sprintf("and growth at the %s CGP.", goal_cgp %>% toOrdinal::toOrdinal())
    ),
    gp = grid::gpar(fontsize = 13)
  )
  
  goal_equiv <- empty_norm_grade_space(
    measurementscale = measurementscale,
    spring_only = TRUE
  )
  
  goal_equiv <- goal_equiv +
    annotate(
      geom = 'point',
      x = this_report$annotate_x, y = this_report$annotate_y,
      shape = 24,
      fill = 'gold1',
      size = 4
    ) +
    coord_cartesian(
      xlim = c(this_report$xmin, this_report$xmax),
      ylim = c(this_report$ymin, this_report$ymax)
    )
  
  idealized_growth <- cgp_sim(
    measurementscale = measurementscale, 
    start_rit = this_report$sim_start, 
    cgp = goal_cgp, 
    sim_over = school_type
  )
  
  idealized_growth <- data.frame(
    grade_seq = idealized_growth$grade_seq,
    rit = idealized_growth$rit_seq
  )
  
  idealized_sim <- goal_equiv +
    geom_text(
      data = idealized_growth,
      aes(x = grade_seq, y = rit, label = rit %>% round()),
      vjust = 1
    ) +
    geom_line(
      data = idealized_growth,
      aes(x = grade_seq, y = rit),
      linetype = 'dashed'
    ) +
    labs(
      title = sprintf(
        "Idealized 'What if?' growth, %s %s", school_type, measurementscale
      )
    )
  
  idealized_sim$layers <- annotate(
    geom = 'text',
    x = (this_report$xmin + this_report$xmax) / 2,
    y = (this_report$ymin + this_report$ymax) / 2,
    label = 'Illustration',
    size = 40,
    angle = 33,
    color = 'hotpink',
    alpha = 0.15
  ) %>% c(idealized_sim$layers)

  left_stack <- gridExtra::arrangeGrob(
    left_exp, idealized_sim, nrow = 2, heights = c(1, 6)
  )
  
  #right
  right_exp <- RGraphics::splitTextGrob(
    paste0(
      "The chart below shows what would happen if this cohort grew ",
      "from their current baseline ",
      sprintf("(RIT %s) ", expectations_df$observed_baseline %>% round(1)),
      sprintf("at CGP %s through the ", goal_cgp),
      sprintf("end of %s ", this_report$annotate_x %>% toOrdinal::toOrdinal()),
      "grade."
    ),
    gp = grid::gpar(fontsize = 13)
  )
  
  start_sim <- expectations_df$start_grade_level_season
  specific_growth <- cgp_sim(
    measurementscale = measurementscale, 
    start_rit = expectations_df$observed_baseline, 
    cgp = goal_cgp, 
    sim_over = c(
      start_sim, seq(expectations_df$end_grade, this_report$annotate_x, 1)
    )
  )
  
  specific_growth <- data.frame(
    grade_seq = specific_growth$grade_seq,
    rit = specific_growth$rit_seq,
    rowids = c(1:length(specific_growth$rit_seq))
  )
  
  specific_growth <- specific_growth %>%
    dplyr::mutate(
      next_rit = lead(rit), 
      year_y = (rit + next_rit) / 2,
      year_label = end_academic_year + rowids
    )
  
  specific_sim <- goal_equiv +
    geom_text(
      data = specific_growth,
      aes(x = grade_seq, y = rit, label = rit %>% round(1)),
      vjust = 1
    ) +
    geom_text(
      data = specific_growth,
      aes(x = grade_seq + 0.5, y = year_y, label = year_label),
      size = 4,
      fontface = 'italic'
    ) +
    geom_line(
      data = specific_growth,
      aes(x = grade_seq, y = rit),
      linetype = 'dashed'
    ) +
    labs(
      title = sprintf(
        "Simulated Growth for this cohort at %s CGP", 
        goal_cgp %>% toOrdinal::toOrdinal()
      )
    )
  
  specific_sim$layers <- annotate(
    geom = 'text',
    x = (this_report$xmin + this_report$xmax) / 2,
    y = (this_report$ymin + this_report$ymax) / 2,
    label = 'Your students!',
    size = 32,
    angle = 33,
    color = 'hotpink',
    alpha = 0.15
  ) %>% c(specific_sim$layers)
  
  right_stack <- gridExtra::arrangeGrob(
    right_exp, specific_sim, nrow = 2, heights = c(1, 6)
  )
  
  sim_header <- gridExtra::arrangeGrob(sim_header_l, sim_header_r, ncol = 2)
  sim_bottom <- gridExtra::arrangeGrob(left_stack, right_stack, ncol = 2)
  
  sim <- gridExtra::arrangeGrob(
    sim_header, sim_bottom, nrow = 2, heights = c(1, 12)
  )
  
  p2_top <- h_var('2. Where do they need to go?', 20)
  p2 <- gridExtra::arrangeGrob(
    goals, sim, nrow = 2, heights = c(1, 3)
  )
  p2 <- gridExtra::arrangeGrob(
    p2_top, p2, nrow = 2, heights = c(1, 17)
  )
  p2 <- report_footer(p2, context)
  
  report_list[[2]] <- p2

  return(report_list)
}


#' Basline and Goals, for printing reports
#'
#' @param mapvizieR_obj a valid mapvizieR object
#' @param studentids vector of studentids
#' @param measurementscale target subject
#' @param start_fws character, starting season for school growth norms
#' @param start_year_offset 0 if start season is same, -1 if start is prior year.
#' @param end_fws ending season
#' @param end_academic_year ending academic year
#' @param end_grade grade level at end of growth window (for lookup)
#' @param start_fws_prefer if more than one start_fws, what is the preferred term?
#' @param calc_for what CGPs to calc for?  vector of integers between 1:99
#' @param output c('both', 'baseline', 'goals')
#' @param font_size how big to print
#'
#' @return gridArrange object of grobs
#' @export

fall_goals_data_table <- function(
  mapvizieR_obj,
  studentids,
  measurementscale,
  start_fws,
  start_year_offset,
  end_fws,
  end_academic_year,
  end_grade,
  start_fws_prefer = NA, 
  calc_for = 80,
  output = 'both',
  font_size = 20
) {
  
  targets_df <- mapviz_cgp_targets(
    mapvizieR_obj, 
    studentids, 
    measurementscale,
    start_fws, 
    start_year_offset, 
    end_fws, 
    end_academic_year,
    end_grade, 
    start_fws_prefer, 
    calc_for
  )

  df <- mv_limit_cdf(mapvizieR_obj, studentids, measurementscale)
  
  if (length(start_fws) == 1) {
    baseline_df <- df %>%
      dplyr::filter(
        fallwinterspring == start_fws &
          map_year_academic == end_academic_year + start_year_offset
      )
    #multiple terms passed
  } else if (length(start_fws) > 1) {
    baseline_df <- preferred_cdf_baseline(
      df, 
      start_fws, 
      start_year_offset, 
      end_fws, 
      end_academic_year, 
      start_fws_prefer
    ) 
  }
  
  baseline_df <- baseline_df %>%
    dplyr::summarize(
      avg_rit = mean(testritscore, na.rm = TRUE),
      avg_npr = mean(consistent_percentile, na.rm = TRUE)
    )
  
  baseline_rit <- baseline_df$avg_rit %>% round(1) %>% unlist() %>% unname()
  target_change <- targets_df$growth_target %>% round(1) %>% unlist() %>% unname()
  
  r1a <- h_var("Baseline: ", font_size)
  r2a <- h_var("Spring Goal: ", font_size)
  
  r1b <- h_var(baseline_rit, font_size)
  r2b <- h_var(
    paste0(baseline_rit + target_change, ' (+', target_change, ')'), font_size
  ) 
  
  r1 <- gridExtra::arrangeGrob(r1a, r1b, ncol = 2)
  r2 <- gridExtra::arrangeGrob(r2a, r2b, ncol = 2)
  
  if (output == 'both') {
    final <- gridExtra::arrangeGrob(r1, r2, nrow = 2)
  } else if (output == 'baseline') {
    final <- r1    
  } else if (output == 'goals') {
    final <- r2
  }
  
  return(final)
}



#' Expectation distribution
#'
#' @param expectations_df output of mapviz_cgp_targets - the expectations
#' data frame
#' @param num_sd how many sds to show?  default is +/- 3 
#' @param ref_lines what CGP reference lines to show?  
#' default is 1, 5, 20, 50, 80, 95, 99
#' @param highlight should we highlight a reference line?  set to -1 if not wanted
#'
#' @return a ggplot object
#' @export

cohort_growth_expectations_plot <- function(
  expectations_df,
  num_sd = 3,
  ref_lines = c(.01, .05, .2, .5, .8, .95, .99),
  highlight = .8
  ) {
  
  c_mean <- expectations_df$typical_cohort_growth
  c_sd <- expectations_df$sd_of_expectation
  
  c_lower <- c_mean + -num_sd * c_sd
  c_upper <- c_mean + num_sd * c_sd
  
  ref_display <- c_mean + (c_sd * qnorm(ref_lines))
  
  out <- ggplot(
    data = data.frame(x = c(-num_sd * c_sd, num_sd * c_sd)), 
    aes(x)
  ) + 
  geom_vline(
    data = data.frame(
      x = ref_display,
      hilite = ref_lines == highlight
    ),
    aes(xintercept = x, color = hilite, size = hilite),
    alpha = 0.5
  ) +
  geom_text(
    data = data.frame(
      x = ref_display,
      cgp = ref_lines * 100,
      helper = ifelse(ref_display >= 0, '+', '')
    ),
    aes(
      x = x,
      label = paste0('CGP ', cgp, ': ', helper, x %>% round(1)),
      y = 0
    ),
    angle = 90,
    vjust = 0,
    hjust = 0,
    size = 3
  ) +
  scale_color_manual(values = c('gray50', 'green3')) +
  scale_size_manual(values = c(.5, 1.25)) +
  stat_function(
    fun = dnorm, 
    args = list(mean = c_mean, sd = c_sd)
  ) +
  theme_bw() +
  theme(
    panel.grid = element_blank(),
    axis.text.y = element_blank(),
    axis.ticks.y = element_blank()
  ) +
  scale_x_continuous(
    breaks = seq(
      round_to_any(c_lower, 2, floor), 
      round_to_any(c_upper, 2, ceiling),
      2
    ),
    limits = c(c_lower, c_upper)
  ) +
  labs(
    x = 'Expected cohort growth (in mean RIT)',
    y = ''
  )
  
  out  
}


#' Fall Goals Report p 1
#'
#' @inheritParams fall_goals_report
#' 
#' @return a multipage report, represented as a list of grobs.
#' @export

fall_goals_report_p1 <- function(
  mapvizieR_obj, 
  studentids, 
  measurementscale, 
  context,
  start_fws = 'Spring',
  start_year_offset = -1,
  end_fws = 'Spring',
  end_academic_year = 2015,
  entry_grade_seasons = c(-0.8, 4.2),
  exclude_prior_year_holdover = TRUE,
  detail_academic_year = 9999,
  goal_cgp = 80,
  school_type = 'MS',
  localization = localize('Newark')
) {

  mapvizieR_obj$cdf <- impute_rit(
    mapvizieR_obj = mapvizieR_obj,
    studentids = studentids, 
    measurementscale = measurementscale
  )
  
  end_grade <- mapvizieR_obj$roster %>%
    dplyr::filter(
      studentid %in% studentids &
        map_year_academic == end_academic_year
    ) %>% 
    dplyr::select(
      grade
    ) %>%
    table() %>% sort() %>% names() %>% rev() %>% 
    magrittr::extract(1) %>% as.numeric()
  
  if (exclude_prior_year_holdover) {
    mapvizieR_obj$cdf <- mapvizieR_obj$cdf %>% dplyr::filter(
      grade < end_grade
    )
  } 

  becca <- becca_plot(
    mapvizieR_obj = mapvizieR_obj, 
    studentids = studentids,
    measurementscale = measurementscale,
    detail_academic_year = detail_academic_year,
    entry_grade_seasons = entry_grade_seasons
  ) + 
  labs(title = 'Historical Quartile Change')
  
  cgp_hist <- cohort_cgp_hist_plot(
    mapvizieR_obj = mapvizieR_obj,
    studentids = studentids,
    measurementscale = measurementscale,
    entry_grade_seasons = entry_grade_seasons
  ) +
  labs(title = 'Historic Cohort Growth Percentiles')
  
  cohort_longitudinal <- cohort_longitudinal_npr_plot(
    mapvizieR_obj = mapvizieR_obj,
    studentids = studentids,
    measurementscale = measurementscale,
    student_alpha = 0.075,
    name_annotations = TRUE
  ) +
  labs(title = 'Historic Student and Cohort Growth')
  
  most_growth <- stu_growth_detail_table(
    mapvizieR_obj = mapvizieR_obj,
    studentids = studentids,
    measurementscale = measurementscale,
    entry_grade_seasons = entry_grade_seasons,
    high_or_low_growth = 'high',
    num_stu = 12,
    title = 'Most Growth'
  ) 
  
  least_growth <- stu_growth_detail_table(
    mapvizieR_obj = mapvizieR_obj,
    studentids = studentids,
    measurementscale = measurementscale,
    entry_grade_seasons = entry_grade_seasons,
    high_or_low_growth = 'low',
    num_stu = 12,
    title = 'Least Growth'
  ) 

  template_04(becca, cgp_hist, cohort_longitudinal, most_growth, least_growth)
}