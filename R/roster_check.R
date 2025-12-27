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
  ensure_roster_names(roster)
  ensure_roster_types(roster)

  all_checks <- is.data.frame(roster)

  return(all_checks)
}



#' @title ensure_roster_names
#'
#' @description does the roster have a studentid and grade field?
#'
#' @param roster roster data frame to check

ensure_roster_names <- function(roster) {
  if (!('studentid' %in% names(roster))) {
    cli::cli_abort("check your roster - it must have a field named studentid.")
  }

  if (!('grade' %in% names(roster))) {
    cli::cli_abort("check your roster - it must have a field named grade.")
  }

  if (!all(c('studentlastname', 'studentfirstname') %in% names(roster))) {
    cli::cli_abort("check your roster - it must have fields named 'studentlastname' and 'studentfirstname'.")
  }

  if (!all(c('studentlastfirst', 'studentfirstlast') %in% names(roster))) {
    cli::cli_abort("check your roster - it must have fields named 'studentlastfirst' and 'studentfirstlast'.\n       these fields are built by `prep_roster()` if reading from NWEA files.\n       if you are generating your own roster file, please include these fields.")
  }

  invisible(roster)
}



#' @title ensure_roster_types
#'
#' @description checks if certain roster fields are of the correct type
#'
#' @param roster roster data frame to check

ensure_roster_types <- function(roster) {
  if (class(roster$grade) != "integer") {
    cli::cli_abort("check type on grade field, should be integer.")
  }
  if (class(roster$map_year_academic) != "integer") {
    cli::cli_abort("check type on map_year_academic field, should be integer.")
  }
  if (class(roster$fallwinterspring) != "character") {
    cli::cli_abort("check type on fallwinterspring, should be character.")
  }

  invisible(roster)
}