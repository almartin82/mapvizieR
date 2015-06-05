#' @title estimate RIT score for a student using regression or interpolation
#' 
#' @description Given studentid, measurementscale, and a target_date, the 
#' function will return an estimated score based on selected method 
#' 
#' @param mapvizieR_obj mapvizieR object
#' @param sid target studentid
#' @param measurescale target subject
#' @param target_date date of interest, %Y-%m-%d format
#' @param method which method to use to estimate RIT score
#' @param foward default is TRUE, set to FALSE if only scores before target_date should be chosen for 'closest' method
#' 
#' @export


estimate_rit <- function(
  mapvizieR_obj,
  sid,
  measurescale,
  target_date,
  method = c('closest','lm','interpolate'),
  forward = TRUE
) {
  
  # throw an error if method is not given
  if (missing(method)) {
    stop('method not given')
  }
  
  # pull out the cdf
  cdf <- mapvizieR_obj[['cdf']]
  
  target_date <- as.Date(target_date)
  
  # find the matchings rows
  if (require(dplyr)) {
    student <- cdf %>% dplyr::filter(studentid == sid,
                                     measurementscale == measurescale)
  } else {
    student <- subset(cdf, studentid == sid & measurementscale == measurescale)
  }
  
  # return error if student does not have take a test for given measurementscale
  if (dim(student)[1] == 0) {
    
    warning('student does not have a test for given measurementscale')
    return(NA)
    
  } else if (dim(student)[1] == 1) {
    
    warning('student only has one test event for given measurementscale')
    return(student$testritscore[1])
    
  }
  
  # if target_date is one of the test dates, return that rit score
  if (target_date %in% student$teststartdate) {
    return(student$testritscore[student$teststartdate == target_date])
  }
  
  # change target_date to data.frame to use for prediction
  predict_date <- data.frame(teststartdate = as.Date(target_date))
  
  if (method == 'closest') {
    # filter out rows after target date if forward = FALSE
    if (!forward) {
      student <- student[student$teststartdate < as.Date(target_date),]
    }
    student <- student[order(student$teststartdate),]
    
    # find closest date and return rit score on that day
    diff <- as.numeric(as.Date(target_date) - student$teststartdate)
    
    return(student$testritscore[match(min(abs(diff)),abs(diff))])
    
  } else if (method == 'lm') {
    fit <- lm(testritscore~teststartdate,student)
    
    return(round(predict(fit,newdata = predict_date)))
    
  } else if (method == 'interpolate' & (target_date < min(student$teststartdate) | target_date > max(student$teststartdate))) {
    
    warning('Cannot interpolate a date before earliest or after latest teststartdate')
    return(NA)
  
  } else if (method =='interpolate') {
    # order student rows by date
    student <- student[order(student$teststartdate),]
    
    diff <- as.numeric(as.Date(target_date) - student$teststartdate)
    
    # get the indices of the test dates that surround the target_date
    loc <- match(min(abs(diff)),abs(diff))
    if(diff[loc] > 0) {
      loc2 <- loc + 1
    } else {
      loc2 <- loc - 1
    }
    
    fit <- lm(testritscore~teststartdate,student[sort(c(loc,loc2)),])
    return(round(predict(fit,newdata=predict_date)))
  }
}