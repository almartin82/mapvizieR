#' @title goal_bar
#' 
#' @description a simple bar chart that shows the percentage of a cohort 
#' 
#' @param mapvizieR_obj mapvizieR object
#' @param studentids target students
#' @param measurementscale target subject
#' @param subgroup_cols what subgroups in mapvizier roster do you want to cut by?  default
#' is starting_quartile
#' @param pretty_names nicely formatted names for the column cuts used above.
#' @param start_fws starting season
#' @param start_academic_year starting academic year
#' @param end_fws ending season
#' @param end_academic_year ending academic year
#' @param complete_obsv if TRUE, limit only to students who have BOTH a start
#' and end score. default is FALSE.
#' 
#' @export

goal_bar <- function(
  mapvizieR_obj, 
  studentids, 
  measurementscale,
  start_fws,
  start_academic_year,
  end_fws,
  end_academic_year,
  complete_obsv = FALSE
) {
  
}