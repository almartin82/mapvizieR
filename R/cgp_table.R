#' @title display table for school/cohort growth percentile (CGP)
#'
#' @param mapvizieR_obj mapvizieR object
#' @param studentids target students
#' @param measurementscale target subject
#' @param start_fws starting season
#' @param start_academic_year starting academic year
#' @param end_fws ending season
#' @param end_academic_year ending academic year
#' @param big_font how big are the stats
#' 
#' @export

cgp_table <- function(
  mapvizieR_obj, 
  studentids,
  measurementscale,
  start_fws, 
  start_academic_year, 
  end_fws, 
  end_academic_year,
  big_font = 50
) {
  
  cgp_df <- mapviz_cgp(mapvizieR_obj, studentids, measurementscale,
    start_fws, start_academic_year, end_fws, end_academic_year)
  
  l1 <- h_var("% Making\nTypical Growth", 13)
  l2 <- h_var("RIT Change", 13)
  l3a <- h_var("Cohort Growth\nPercentile", 13)
  l3b <- grob_justifier(
    textGrob(paste0('(', start_fws, ' to ', end_fws, ')'), gp = grid::gpar(fontsize = 10)), 
    "center", "center"
  )
  l3 <- gridExtra::arrangeGrob(l3a, l3b, nrow = 2, heights = c(2, 1))
  
  s1 <- h_var(paste0(round(cgp_df$percent_typ * 100, 0), '%'), big_font)
  s2 <- h_var(paste0(ifelse(cgp_df$avg_rit_change >= 0, '+',''), round(cgp_df$avg_rit_change, 1)), big_font)
  s3 <- h_var(toOrdinal::toOrdinal(round(cgp_df$cgp, 0)), big_font)
  
  r1 <- gridExtra::arrangeGrob(l1, l2, l3, ncol = 3)
  r2 <- gridExtra::arrangeGrob(s1, s2, s3, ncol = 3)
  
  final <- gridExtra::arrangeGrob(r1, r2, nrow = 2, heights = c(2, 3))
  
  return(final)
}