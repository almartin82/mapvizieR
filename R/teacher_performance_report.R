#' @title Teacher Performance Update
#'
#' @param mapvizieR_obj mapvizieR object
#' @param studentids target students
#' @param measurementscale target subject
#' @param start_fws starting season
#' @param start_academic_year starting academic year
#' @param end_fws ending season
#' @param end_academic_year ending academic year
#' @param title_text what is this report called?
#' @param ... additional arguments
#'
#' @return prints a ggplot object
#'
#' @export

teacher_performance_update <- function(
  mapvizieR_obj, studentids, measurementscale,
  start_fws, start_academic_year, end_fws, end_academic_year,
  title_text = '',
  ...
) {

  minimal = rectGrob(gp = gpar(col = "white"))

  title_bar <- h_var(paste0('Teacher Performance Update: ', title_text), 24)

  #elephants
  ele <- galloping_elephants(mapvizieR_obj, studentids, measurementscale)

  #histogram
  growth_hist <- growth_histogram(
    mapvizieR_obj = mapvizieR_obj,
    studentids = studentids,
    measurementscale = measurementscale,
    start_fws = start_fws,
    start_academic_year = start_academic_year,
    end_fws = end_fws,
    end_academic_year = end_academic_year
  )

  arrangeGrob(
    title_bar, ele, growth_hist,
    nrow = 3, heights = c(1,4,4)
  )
}
