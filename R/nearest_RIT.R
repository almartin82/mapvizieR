#' @title find nearest RIT score for a student, by date
#' 
#' @description Given studentid, measurementscale, and a target_date, the function will return 
#' the closest RIT score. 
#' 
#' @param mapvizieR_obj mapvizieR object
#' @param studentid target studentid
#' @param measurementscale target subject
#' @param target_date date of interest, \code{Y-m-d} format
#' @param num_days function will only return test score within num_days of target_date
#' @param forward default is TRUE, set to FALSE if only scores before target_date should be chosen
#' 
#' @export


nearest_rit <- function(
  mapvizieR_obj,
  studentid,
  measurementscale,
  target_date,
  num_days=180,
  forward=TRUE
) {

  # check that measurementscale is given / valid
  if (missing(measurementscale)) {
    stop('measurementscale not given')
  } else if (!(measurementscale %in% c('General Science','Language Usage','Mathematics','Reading'))) {
    stop('invalid measurementscale')
  }
  
  # pull out the cdf
  cdf <- mapvizieR_obj[['cdf']]
  
  # find the matchings rows
  student <- cdf[(cdf$studentid == studentid & cdf$measurementscale == measurementscale),]

  if (!(studentid %in% cdf$studentid)) {
    stop('studentid not in mapvizieR cdf object')
  }
  
  # filter out rows if forward = FALSE
  if (!forward) {
    student <- student[student$teststartdate <= as.Date(target_date),]
  }
  student <- student[order(student$teststartdate),]

  # find closest date and return rit score on that day
  diff <- as.numeric(as.Date(target_date) - student$teststartdate)
  
  if (min(abs(diff)) <= num_days) {
    return(student$testritscore[match(min(abs(diff)),abs(diff))])
  } else {
    warning('no test score within num_days')
    return(NA)
  }
  
  
}