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
  
  cdf_long <- cdf_long %>% 
    #names
    lower_df_names() %>%
    #fallwinterspring, academic_year
    extract_academic_year()  
  
  assert_that(check_cdf_long(cdf_long)$boolean)
  
  return(cdf_long)
}
