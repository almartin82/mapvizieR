
#' Title
#'
#' @param mapvizieR_object a valid mapvizieR_object
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
  mapvizieR_object, 
  studentids, 
  measurementscale, 
  context,
  start_fws = 'Spring',
  start_year_offset = -1,
  end_fws = 'Spring',
  end_academic_year = 2015,
  entry_grade_seasons = c(-0.8, 4.2)
) {
  
  report_list <- list()
  
  #1. Where have my students been?
  p1a <- h_var('1. Where have my students been?', 36)
  p1a <- report_footer(p1a, context)
  
  report_list[[1]] <- p1a
  
  becca <- becca_plot(
    mapvizieR_obj = mapvizieR_obj, 
    studentids = studentids,
    measurementscale = measurementscale,
    detail_academic_year = detail_academic_year,
    entry_grade_seasons = entry_grade_seasons
  )

  #2. Where do they need to go?
  p2a <- h_var('2. Where do they need to go?', 36)
  p2a <- report_footer(p2a, context)
  
  report_list[[3]] <- p2a
  
  return(report_list)
}
