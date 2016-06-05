#' ny linking
#'
#' @param measurementscale MAP subject
#' @param current_grade grade level
#' @param season c('Fall', 'Winter', 'Spring')
#' @param RIT rit score
#' @param returns one of c('perf_level', 'proficient')
#'
#' @return either character, length 1 with performance level or logical, 
#' length 1, with proficiency
#' @export

ny_linking <- function(measurementscale, current_grade, season, RIT, returns = 'perf_level') {
 
  out <- ny_predicted_proficiency %>%
    dplyr::filter(
      ny_subj == measurementscale,
      ny_grade == current_grade,
      ny_season == season,
      ny_rit == RIT
    )
  
  if (nrow(out)==0) {
    out <- NA
  } else {
    out <- out[, returns] %>% unlist %>% unname()  
  }
  
  out 
}