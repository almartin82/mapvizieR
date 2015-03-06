#' @title calc_baseline_detail
#'
#' @description
#' given a mapvizieR object, a vector of studentids, a subject, and a target term, return 
#' a data frame of students and their baseline RIT scores. 
#' also has a fallback option - for instance, imagine you
#' were using a prior Spring score as baseline, but if a student was a new admit
#' in the fall, you wanted to roll them into the baseline.
#'
#' @param mapvizieR_obj mapvizieR object
#' @param studentids target students
#' @param measurementscale target subject
#' @param target_fws fall winter spring of primary/desired baseline
#' @param target_academic_year academic year of primary/desired baseline
#' @param fallback_fws fall winter spring of fallback/backup baseline
#' @param fallback_academic_year academic year of fallback/backup baseline

calc_baseline_detail <- function(
  mapvizieR_obj, 
  studentids, 
  measurementscale, 
  target_fws,
  target_academic_year,
  fallback_fws = NA,
  fallback_academic_year = NA
) {
  #data validation
  mv_opening_checks(mapvizieR_obj, studentids, 1)

  #unpack the mapvizieR object and limit to desired students
  this_cdf <- mv_limit_cdf(mapvizieR_obj, studentids, measurementscale)
  
  minimal_cdf <- this_cdf[with(this_cdf, fallwinterspring == target_fws &
      map_year_academic == target_academic_year), c('studentid', 'testritscore')]
  
  #term 1
  munge <- dplyr::left_join(
    x = data.frame(studentid=studentids),
    y = minimal_cdf,
    by = "studentid"
  )  
  names(munge)[[2]] <- 'target_RIT'

  if (all(is.na(fallback_fws), fallback_academic_year)) {
    #if there's no fallback, just generate a dummy column of NAs.
    munge$fallback_RIT <- NA
  } else {
    munge <- left_join(
      munge,
      this_cdf[with(this_cdf, fallwinterspring == fallback_fws &
        map_year_academic == fallback_academic_year), c('studentid', 'testritscore')],
      by = "studentid"
    )
    names(munge)[[3]] <- 'fallback_RIT'    
  }
  
  #take target it 
  munge$baseline_RIT <- ifelse(is.na(munge$target_RIT), munge$fallback_RIT, munge$target_RIT)
  
  return(munge[ , c('studentid', 'baseline_RIT')])
}
