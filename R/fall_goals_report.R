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
#' @param detail_academic_year passed through to various plots
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
  detail_academic_year = 9999
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
  
  becca <- becca_plot(
    mapvizieR_obj = mapvizieR_obj, 
    studentids = studentids,
    measurementscale = measurementscale,
    detail_academic_year = detail_academic_year,
    entry_grade_seasons = entry_grade_seasons
  )
  
  cgp_hist <- cohort_cgp_hist_plot(
    mapvizieR_obj = mapvizieR_obj,
    studentids = studentids,
    measurementscale = measurementscale,
    entry_grade_seasons = entry_grade_seasons
  ) 
  
  cohort_longitudinal <- cohort_longitudinal_npr_plot(
    mapvizieR_obj = mapvizieR_obj,
    studentids = studentids,
    measurementscale = measurementscale,
    student_alpha = 0.075,
    name_annotations = TRUE
  ) 
  
  most_growth <- stu_growth_detail_table(
    mapvizieR_obj = mapvizieR_obj,
    studentids = studentids,
    measurementscale = measurementscale,
    entry_grade_seasons = entry_grade_seasons,
    high_or_low_growth = 'high',
    num_stu = 10
  )

  least_growth <- stu_growth_detail_table(
    mapvizieR_obj = mapvizieR_obj,
    studentids = studentids,
    measurementscale = measurementscale,
    entry_grade_seasons = entry_grade_seasons,
    high_or_low_growth = 'low',
    num_stu = 10
  )
  
  p1_top <- h_var('1. Where have my students been?', 12)
  
  
  left_stack <- gridExtra::arrangeGrob(becca, cgp_hist, nrow = 2)
  right_stack <- gridExtra::arrangeGrob(most_growth, least_growth, nrow = 2)
  
  p1_main <- gridExtra::arrangeGrob(
    left_stack, cohort_longitudinal, right_stack, 
    ncol = 3, widths = c(1, 2, 1)
  )
  
  p1 <- gridExtra::arrangeGrob(
    p1_top, p1_main, nrow = 2, heights = c(1, 15)
  )
  p1 <- report_footer(p1, context)
  
  report_list[[1]] <- p1

  
  #2. Where do they need to go?
  end_grade <- mapvizieR_obj$roster %>%
    dplyr::filter(
      studentid %in% studentids &
        map_year_academic == end_academic_year
    ) %>% 
    dplyr::select(
      grade
    ) %>%
    table() %>% names() %>% extract(1)
  
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
    calc_for = 80
  )
  
  goals_chart_explanation <- h_var(
    "Our goal is for this cohort to grow \nin the top 20% of cohorts nationally.",
    20
  )
  goals_chart <- gridExtra::arrangeGrob(
    goals_chart_explanation, minimal, nrow = 2, heights = c(1, 3)
  )
  
  goals <- gridExtra::arrangeGrob(
    goals_words, goals_chart, ncol = 2
  )
  
  sim <- minimal
  
  p2_top <- h_var('2. Where do they need to go?', 36)
  p2 <- gridExtra::arrangeGrob(
    goals, sim, nrow = 2, heights = c(1, 3)
  )
  p2_main <- report_footer(p2, context)
  
  report_list[[2]] <- p2
  
  return(report_list)
}


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
  calc_for = 80
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
  
  r1a <- h_var("Start: ", 20)
  r2a <- h_var("Goal: ", 20)
  
  r1b <- h_var(baseline_rit, 26)
  r2b <- h_var(
    paste0(baseline_rit + target_change, ' (+', target_change, ')'), 26
  ) 
  
  r1 <- gridExtra::arrangeGrob(r1a, r1b, ncol = 2)
  r2 <- gridExtra::arrangeGrob(r2a, r2b, ncol = 2)
  
  final <- gridExtra::arrangeGrob(r1, r2, nrow = 2)
  
  return(final)
}

