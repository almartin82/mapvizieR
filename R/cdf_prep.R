
#' @title cdf_prep_names
#'
#' @description
#' \code{cdf_prep_names} turns the CamelCase names of a cdf to lowercase.
#'
#' @param cdf_long a map assessmentresults.csv file.  can be one term, or many terms
#' together in one file.
#' @return a cdf with lowercase variable names
#' 
#' @examples
#' add(1, 1)

cdf_prep_names <- function(cdf_long) {
  
  names(cdf_long) <- tolower(names(cdf_long))
  
  return(cdf_long)
}



#' @title cdf_prep_fws
#'
#' @description
#' \code{cdf_prep_fws} munges test term data on a CDF
#'
#' @param cdf_long a map assessmentresults.csv file.  can be one term, or many terms
#' together in one file.
#' @return a cdf with new term fields 
#' 
#' @examples
#' add(1, 1)



cdf_prep_fws <- function(cdf_long) {
  
  prep1 <- do.call(
    what = rbind,
    args = strsplit(x = cdf_long$termname, split = " ", fixed = T)
  )
  
  cdf_long$fallwinterspring <- prep1[ ,1]
  #the calendar year of the test date
  cdf_long$year_tested <- lubridate::year(
    as.Date(cdf_long$teststartdate, "%m/%d/%Y")
  )
  
  #the academic year of the test date
  prep2 <- do.call(
    what = rbind,
    args = strsplit(x = prep1[ , 2], split = "-", fixed = T)
  )
  
  cdf_long$map_year_academic <- prep2[ ,1]

  return(cdf_long)
}



#' @title prep_cdf
#'
#' @description
#' \code{prep_cdf} a wrapper around several cdf prep functions
#'
#' @param cdf_long a map assessmentresults.csv file.  can be one term, or many terms
#' together in one file.
#' @return a prepped cdf file 
#' 
#' @examples
#' add(1, 1)

prep_cdf <- function(cdf_long) {
  
  cdf_long <- cdf_prep_names(cdf_long)
  cdf_long <- cdf_prep_fws(cdf_long)
  
  return(cdf_long)
}
