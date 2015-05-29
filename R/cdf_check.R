utils::globalVariables(c("assert_that", "select", "ends_with", "has_name", "on_failure"))

#' @title check_cdf_long
#'
#' @description
#' \code{check_cdf_long} a wrapper around a bunch of individual tests
#' that see if a CDF data frame conforms to mapvizieR conventions
#'
#' @param prepped_cdf_long a map CDF file, generated either by prep_cdf_long,
#' or via processing done in your data warehouse
#'  
#' @return a named list.  \code{$boolean} has true false result; \code{descriptive} 
#' has a more descriptive string describing what happened.
#' 
#' @export


check_cdf_long <- function(prepped_cdf_long) {
  
  #column/header names
  names_result <- check_cdf_names(prepped_cdf_long)
  
  #fallwinterspring
  season_result <- check_cdf_fws(prepped_cdf_long)
    
  result_vector <- c(names_result, season_result)
  results <- list(
    boolean=all(result_vector),
    descriptive=paste0("passed ", length(result_vector[result_vector==TRUE]), " tests!")
  )
  
  return(results)
}



#' @title check_processed_cdf
#' 
#' @description the mapvizieR takes a cdf + a roster and does some grade level lookup.
#' this function is a wrapper around some tests that make sure that
#' the output conforms to expectations
#' 
#' @param processed_cdf output of mapvizieR.default
#' 
#' @return a named list.  \code{$boolean} has true false result; \code{descriptive} 
#' has a more descriptive string describing what happened.


check_processed_cdf <- function(processed_cdf) {
  
  #encompasses check_cdf_long 
  basic_result <- check_cdf_long(processed_cdf)$boolean

  #column/header names
  names_result <- check_processed_names(processed_cdf)
      
  result_vector <- c(basic_result, names_result)
  results <- list(
    boolean=all(result_vector),
    descriptive=paste0("passed ", length(result_vector[result_vector==TRUE]), " tests!")
  )
  
  return(results)
}




#' @title check_cdf_names
#'
#' @description
#' \code{check_cdf_names} tests a prepped cdf's names to see if they conform
#'
#' @inheritParams check_cdf_long
#'  
#' @return boolean, does the cdf pass?

check_cdf_names <- function(prepped_cdf_long) {
  
  #the names of the data frame should include the following
  expected_names <- c("termname", "studentid", "schoolname", "measurementscale", "discipline", 
    "growthmeasureyn", "testtype", "testname", "testid", "teststartdate", 
    "testdurationminutes", "testritscore", "teststandarderror", "testpercentile", 
    "typicalfalltofallgrowth", "typicalspringtospringgrowth", 
    "typicalfalltospringgrowth", "typicalfalltowintergrowth", "rittoreadingscore", 
    "rittoreadingmin", "rittoreadingmax", "goal1name", "goal1ritscore", 
    "goal1stderr", "goal1range", "goal1adjective", "goal2name", "goal2ritscore", 
    "goal2stderr", "goal2range", "goal2adjective", "goal3name", "goal3ritscore", 
    "goal3stderr", "goal3range", "goal3adjective", "goal4name", "goal4ritscore", 
    "goal4stderr", "goal4range", "goal4adjective", "goal5name", "goal5ritscore", 
    "goal5stderr", "goal5range", "goal5adjective", "goal6name", "goal6ritscore", 
    "goal6stderr", "goal6range", "goal6adjective", "goal7name", "goal7ritscore", 
    "goal7stderr", "goal7range", "goal7adjective", "goal8name", "goal8ritscore", 
    "goal8stderr", "goal8range", "goal8adjective", "teststarttime", 
    "percentcorrect", "projectedproficiency", "fallwinterspring", 
    "map_year_academic")
  names_test <- all(has_name(prepped_cdf_long, expected_names))
  
  has_valid_names <- function(x) {x==TRUE}
  on_failure(has_valid_names) <- function(call, env) {
    mask <- ! expected_names %in% names(prepped_cdf_long) 
    failed_names <- expected_names[mask]
    msg <- paste0("Your CDF failed the VALID NAMES test.\n",
     "Your CDF is missing the following fields that are required\n",
     "by mapvizieR:\n", paste(failed_names, collapse=', '))
    
    return(msg)
  }
  assertthat::assert_that(has_valid_names(names_test))
  
  return(names_test)
  
}




#' @title check_cdf_fws
#'
#' @description
#' \code{check_cdf_fws} tests the fallwinterspring column of a prepped cdf to
#' see if it conforms
#'
#' @inheritParams check_cdf_long
#'  
#' @return boolean, does the cdf pass?

check_cdf_fws <- function(prepped_cdf_long) {
  
  #fallwinterspring must not be anything other than a season
  seasons_present <- unique(prepped_cdf_long$fallwinterspring)
  valid_seasons <- c('Fall', 'Winter', 'Spring', 'Summer')
  season_test <- all(seasons_present %in% valid_seasons)

  has_valid_seasons <- function(x) {x==TRUE}
  on_failure(has_valid_seasons) <- function(call, env) {
    mask <- !seasons_present %in% valid_seasons
    failed_seasons <- seasons_present[mask]
    msg <- paste0("Your CDF failed the VALID SEASONS test.\n",
     "The fallwinterspring field in your CDF has invalid data.\n",
     "the invalid values are:\n", paste(failed_seasons, collapse=', '))
    
    return(msg)
  }
  assertthat::assert_that(has_valid_seasons(season_test))
  
  return(season_test)
}






#' @title check_processed_names
#' 
#' @description does the processed cdf have the right field names
#' 
#' @inheritParams check_processed_cdf
#' 
#' @return boolean, does the processed cdf pass?
#' 

check_processed_names <- function(processed_cdf) {
  
  #the names of the data frame should include the following
  expected_names <- c("grade", "grade_level_season", 
    "grade_season_label", "consistent_percentile")
  names_test <- all(has_name(processed_cdf, expected_names))
  
  has_valid_names <- function(x) {x==TRUE}
  on_failure(has_valid_names) <- function(call, env) {
    mask <- ! expected_names %in% names(processed_cdf) 
    failed_names <- expected_names[mask]
    msg <- paste0("Your processed CDF failed the VALID NAMES test.\n",
     "Your CDF is missing the following fields that are required\n",
     "by mapvizieR:\n", paste(failed_names, collapse=', '))
    
    return(msg)
  }
  assertthat::assert_that(has_valid_names(names_test))
  
  return(names_test)
  
}
