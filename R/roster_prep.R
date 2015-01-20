
#' @title roster_prep_names
#'
#' @description
#' \code{roster_prep_names} turns the CamelCase names of a StudentsBySchool to lowercase.
#'
#' @param students_by_school one, or multiple (combined) NWEA MAP studentsbyschool.csv file(s).  
#' @return a roster with lowercase data frame names

roster_prep_names <- function(students_by_school) {
  return(lower_df_names(students_by_school))
}
