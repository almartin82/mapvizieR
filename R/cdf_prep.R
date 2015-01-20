#' @title prep_cdf_long
#'
#' @description
#' \code{prep_cdf_long} a wrapper around several cdf prep functions
#'
#' @param cdf_long a map assessmentresults.csv file.  can be one term, or many terms
#' together in one file.
#' 
#' @return a prepped cdf file
#' 
#' @export

prep_cdf_long <- function(cdf_long) {
  
  #names
  cdf_long <- cdf_prep_names(cdf_long)
  #fallwinterspring
  cdf_long <- extract_academic_year(cdf_long)
  
  assert_that(check_cdf_long(cdf_long)$boolean)
  
  return(cdf_long)
}



#' @title cdf_prep_names
#'
#' @description
#' \code{cdf_prep_names} turns the CamelCase names of a cdf to lowercase.
#'
#' @inheritParams prep_cdf_long
#' 
#' @return a cdf with lowercase data frame names

cdf_prep_names <- function(cdf_long) {
  return(lower_df_names(cdf_long))
}