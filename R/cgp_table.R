#' @title display table for school/cohort growth percentile (CGP)
#'
#' @param mapvizieR_obj mapvizieR object
#' @param studentids target students
#' @param measurementscale target subject
#' @param start_fws starting season
#' @param start_academic_year starting academic year
#' @param end_fws ending season
#' @param end_academic_year ending academic year
#' 
#' @export

cgp_table <- function(
  mapvizieR_obj, 
  studentids,
  measurementscale,
  start_fws, 
  start_academic_year, 
  end_fws, 
  end_academic_year
) {
  
  cgp_df <- mapviz_cgp(mapvizieR_obj, studentids, measurementscale,
    start_fws, start_academic_year, end_fws, end_academic_year)
  
  l1 <- h_var("% Making\nTypical Growth", 12)
  l2 <- h_var("RIT Change", 12)
  l3 <- h_var("Cohort Growth Percentile", 12)
  
  s1 <- h_var(paste0(round(cgp_df$percent_typ * 100, 0), '%'), 60)
  s2 <- h_var(paste0(ifelse(cgp_df$avg_rit_change >= 0, '+',''), round(cgp_df$avg_rit_change, 1)), 60)
  s3 <- h_var(toOrdinal::toOrdinal(round(cgp_df$cgp, 0)), 60)
  
  r1 <- gridExtra::arrangeGrob(l1, l2, l3, ncol = 3)
  r2 <- gridExtra::arrangeGrob(s1, s2, s3, ncol = 3)
  
  final <- gridExtra::arrangeGrob(r1, r2, nrow = 2, heights = c(1, 3))
  
  return(final)
}