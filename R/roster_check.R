#' @title check_roster
#'
#' @description
#' \code{check_roster} a wrapper around a bunch of individual tests
#' that see if a roster data frame conforms to mapvizieR expectations
#'
#' @param roster a roster file, generated either by prep_roster,
#' or via processing done in your data warehouse
#'  
#' @return a named list.  \code{$boolean} has true false result; \code{descriptive} 
#' has a more descriptive string describing what happened.
#' 
#' @export


check_roster <- function(roster) {
  #column/header names
  all_checks <- is.data.frame(
    roster %>%
      ensure_roster_names %>%
      ensure_roster_types
  )
  
  return(all_checks)
}



#' @title ensure_roster_names
#' 
#' @description does the roster have a studentid and grade field?
#' 
#' @inheritParams ensure_is_mapvizieR

ensure_roster_names <- ensurer::ensures_that(
    c('studentid') %in% names(.) ~ 
      "check your roster - it must have a field named studentid.",
    c('grade') %in% names(.) ~ 
      "check your roster - it must have a field named grade."
)



#' @title ensure_roster_types
#' 
#' @description checks if certain roster fields are of the correct type
#' 
#' @inheritParams ensure_is_mapvizieR

ensure_roster_types <- ensurer::ensures_that(  
  class(.$grade) == "integer" ~ 
    "check type on grade field, should be integer.",
  class(.$map_year_academic) == "integer" ~ 
    "check type on map_year_academic field, should be integer.",
  class(.$fallwinterspring) == "character" ~ 
    "check type on fallwinterspring, should be character."
)