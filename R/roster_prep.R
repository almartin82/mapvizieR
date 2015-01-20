#' @title prep_roster
#'
#' @description
#' \code{prep_roster} a wrapper around several roster prep functions
#'
#' @param students_by_school one, or multiple (combined) NWEA MAP 
#' studentsbyschool.csv file(s).  
#'
#' @return a prepped roster file
#' 
#' @export

prep_roster <- function(roster) {
  
  #df names
  roster <- roster_prep_names(roster)
  #year prep stuff
  roster <- extract_academic_year(roster)
  
  #check that roster conforms to our expectations
  assert_that(check_roster(roster)$boolean)
  
  return(roster)
}



#' @title roster_prep_names
#'
#' @description
#' \code{roster_prep_names} turns the CamelCase names of a StudentsBySchool to lowercase.
#'
#' @inheritParams prep_roster
#' 
#' @return a roster with lowercase data frame names

roster_prep_names <- function(students_by_school) {
  return(lower_df_names(students_by_school))
}


