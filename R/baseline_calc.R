#' @title calc_baseline_detail
#'
#' @description
#' given a mapvizieR object, a vector of studentids, a subject, and a primary term, return 
#' a data frame of students and their baseline RIT scores. 
#' also has a fallback option - for instance, imagine you
#' were using a prior Spring score as baseline, but if a student was a new admit
#' in the fall, you wanted to roll them into the baseline.
#'
#' @param mapvizieR_obj mapvizieR object
#' @param studentids target students
#' @param measurementscale target subject
#' @param primary_fws fall winter spring of primary/desired baseline
#' @param primary_academic_year academic year of primary/desired baseline
#' @param fallback_fws fall winter spring of fallback/backup baseline
#' @param fallback_academic_year academic year of fallback/backup baseline

calc_baseline_detail <- function(
  mapvizieR_obj, 
  studentids, 
  measurementscale, 
  primary_fws,
  primary_academic_year,
  fallback_fws = NA,
  fallback_academic_year = NA
) {
  #data validation
  mv_opening_checks(mapvizieR_obj, studentids, 1)

  #unpack the mapvizieR object and limit to desired students
  this_cdf <- mv_limit_cdf(mapvizieR_obj, studentids, measurementscale)
  
  minimal_cdf <- this_cdf[with(this_cdf, fallwinterspring == primary_fws &
      map_year_academic == primary_academic_year), 
      c('testid', 'studentid', 'testritscore', 'consistent_percentile')]
  
  #term 1
  munge <- dplyr::left_join(
    x = data.frame(studentid = studentids, stringsAsFactors = FALSE),
    y = minimal_cdf,
    by = "studentid"
  )  
  names(munge)[names(munge) == 'testritscore'] <- 'primary_RIT'
  names(munge)[names(munge) == 'consistent_percentile'] <- 'primary_npr'
  names(munge)[names(munge) == 'testid'] <- 'primary_id'
  
  fallback_cdf <- this_cdf[with(this_cdf, fallwinterspring == fallback_fws &
        map_year_academic == fallback_academic_year), 
        c('testid', 'studentid', 'testritscore', 'consistent_percentile')]
  
  #if there's no fallback, just generate a dummy column of NAs.
  if (all(is.na(fallback_fws), is.na(fallback_academic_year))) {
    munge$fallback_RIT <- NA
    munge$fallback_npr <- NA
    munge$fallback_id <- NA
  #otherwise join to the fallback cdf and get the rit and percentile
  } else {
    munge <- dplyr::left_join(
      x = munge,
      y = fallback_cdf,
      by = "studentid"
    )
    names(munge)[names(munge) == 'testritscore'] <- 'fallback_RIT'
    names(munge)[names(munge) == 'consistent_percentile'] <- 'fallback_npr'
    names(munge)[names(munge) == 'testid'] <- 'fallback_id'
  }
  
  #take primary or fallback based on data 
  munge$baseline_RIT <- ifelse(is.na(munge$primary_RIT), munge$fallback_RIT, munge$primary_RIT)
  munge$baseline_npr <- ifelse(is.na(munge$primary_npr), munge$fallback_npr, munge$primary_npr)
  munge$testid <- ifelse(is.na(munge$primary_RIT), munge$fallback_id, munge$primary_id)
  
  return(munge[ , c('testid', 'studentid', 'baseline_RIT')])
}
