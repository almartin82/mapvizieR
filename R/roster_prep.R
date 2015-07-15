#' @title prep_roster
#'
#' @description
#' \code{prep_roster} a wrapper around several roster prep functions
#'
#' @param students_by_school one, or multiple (combined) NWEA MAP 
#' studentsbyschool.csv file(s).
#' @param kinder_codes alternative grade codes for kindergarten (e.g., "k",
#' "kinder", "Kinder") that need to be translated to grade 0.  Note that code "K" 
#' and 13 are already checked by \code{\link{standardize_kinder}}.   
#'
#' @return a prepped roster file
#' 
#' @export

prep_roster <- function(students_by_school, kinder_codes=NULL) {
  
  #df names
  roster <- students_by_school %>%
    lower_df_names()
  
  #year prep stuff
  roster <- extract_academic_year(roster)
  
  # translate kindergarten ("K", 13, etc) to grade 0
  roster$grade <- standardize_kinder(roster$grade, other_codes = kinder_codes)
  
  roster$studentlastfirst <- paste0(roster$studentlastname, ', ', roster$studentfirstname)
  roster$studentfirstlast <- paste0(roster$studentfirstname, ' ', roster$studentlastname)
  
  #implicit cohort
  roster$implicit_cohort <- roster$map_year_academic + 13 - roster$grade
  
  #check that roster conforms to our expectations
  assertthat::assert_that(check_roster(roster))
  
  return(roster)
}
