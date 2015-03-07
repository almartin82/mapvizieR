#' @title nyt_subgroups
#' 
#' @description the times did a nice job capturing change in the population vs
#' change in subgroups: http://nyti.ms/1tQrOIl 
#' let's do the same thing for change in RIT score.
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

nyt_subgroups <- function(
  mapvizieR_obj, 
  studentids, 
  measurementscale,
  start_fws,
  start_academic_year,
  end_fws,
  end_academic_year
) {
  #data validation and unpack
  mv_opening_checks(mapvizieR_obj, studentids, 1)

  #unpack the mapvizieR object and limit to desired students
  this_cdf <- mv_limit_cdf(mapvizieR_obj, studentids, measurementscale)

  #data processing
  
  #make plot
  
}
