#' @title schambach_table
#' 
#' @description use similar methods in quealy_subgroups to creat tables based on tables
#' Lindsay Schambach is making
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

schambach_table <- function(
  mapvizieR_obj, 
  studentids, 
  measurementscale,
  subgroup_cols = c('starting_quartile'),
  pretty_names = c('Starting Quartile'),
  start_fws,
  start_academic_year,
  end_fws,
  end_academic_year,
  complete_obsv = FALSE
) {
  
}