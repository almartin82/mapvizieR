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
#' @param mapviz mapvizieR object
#' @param first_and_spring_only show all terms, or only entry & spring?  default is TRUE.
#' @param entry_grade_seasons which grade_level_seasons are entry grades?
#' @param detail_academic_year don't mask any data for this academic year
#' @param color_scheme only 'KIPP Report Card'
#' @param small_n_cutoff drop a grade_level_season if less than x% of the max? 
#' (useful when dealing with weird cohort histories)
#' 
#' @return prints a ggplot object
#' 
#' @export

becca_plot <- function(mapviz, first_and_spring_only=TRUE, 
  entry_grade_seasons=c(-0.8, 4.3), detail_academic_year=2014) {
  
  
}