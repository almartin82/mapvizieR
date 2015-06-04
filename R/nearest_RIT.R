#' @title find nearest RIT score for a student, by date
#' 
#' @description Given studentid, measurementscale, and a target_date, the function will return the closest RIT score. 
#' 
#' @param mapvizieR_obj mapvizieR object
#' @param sid target studentid
#' @param measurescale target subject
#' @param target_date date of interest, %Y-%m-%d format
#' @param foward default is TRUE, set to FALSE if only scores before target_date should be chosen
#' 
#' @export


nearest_rit <- function(
  mapvizieR_obj,
  sid,
  measurescale,
  target_date,
  forward=TRUE
) {

  # pull out the cdf
  cdf <- mapvizieR_obj[['cdf']]
  
  # find the matchings rows
  if (require(dplyr)) {
    student <- cdf %>% dplyr::filter(studentid == sid,
                                     measurementscale == measurescale)
  } else {
    student <- subset(cdf, studentid == sid & measurementscale == measurescale)
  }

  # filter out rows if forward = FALSE
  if (!forward) {
    student <- student[student$teststartdate <= as.Date(target_date),]
  }
  student <- student[order(student$teststartdate),]

  # find closest date and return rit score on that day
  diff <- as.numeric(as.Date(target_date) - student$teststartdate)
  
  return(student$testritscore[match(min(abs(diff)),abs(diff))])
  
}