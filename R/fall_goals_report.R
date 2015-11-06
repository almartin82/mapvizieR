
#' Title
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
  p1a <- h_var('1. Where have my students been?', 36)
  p1a <- report_footer(p1a, context)
  
  report_list[[1]] <- p1a
  
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
    student_alpha = 0.075
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
  
  stu_growth_detail_table(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Mathematics',
    entry_grade_seasons = c(-0.8, 5.2)
  )
  
  
  left_stack <- arrangeGrob(becca, cgp_hist, nrow = 2)
  right_stack <- arrangeGrob(most_growth, least_growth, nrow = 2)
  
  p1b <- arrangeGrob(
    left_stack, cohort_longitudinal, right_stack, 
    ncol = 3, widths = c(1, 2, 1)
  )
  p1b <- report_footer(p1b, context)
  
  report_list[[2]] <- p1b

  #2. Where do they need to go?
  p2a <- h_var('2. Where do they need to go?', 36)
  p2a <- report_footer(p2a, context)
  
  report_list[[3]] <- p2a
  
  return(report_list)
}
