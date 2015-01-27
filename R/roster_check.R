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
  names_result <- check_roster_names(roster)
  
  #grade 
  grades_result <- check_roster_grades(roster)
  
  result_vector <- c(names_result, grades_result)
  results <- list(
    boolean=all(result_vector),
    descriptive=paste0("passed ", length(result_vector[result_vector==TRUE]), " tests!")
  )
  
  return(results)
}



#' @title check_roster_names
#' 
#' @description
#' \code{check_roster_names} does the roster have a studentid field?
#' 
#' @param roster a roster file, generated either by prep_roster,
#' or via processing done in your data warehouse
#' 
#' @return boolean

check_roster_names <- function(roster) {
  
  #the roster df has to have a studentid field
  studentid_test <- 'studentid' %in% names(roster)

  #write a custom failure message to make the test more helpful
  has_studentid <- function(x) {x==TRUE}
  on_failure(has_studentid) <- function(call, env) {
    msg <- paste0("Your roster failed the NAMES test.\n",
     "Make sure that your roster data frame contains a field called studentid.")
    return(msg)
  }
  assert_that(has_studentid(studentid_test))
  
  #return the test result
  return(studentid_test)
}

check_roster_grades <- function(roster) {
  
  #the roster df has to have a grade field
  grade_col_test <- 'grade' %in% names(roster)
  
  #write a custom failure message to make the test more helpful
  has_grade <- function(x) {x==TRUE}
  on_failure(has_grade) <- function(call, env) {
    msg <- paste0("Your roster failed the GRADE field test.\n",
                  "Make sure that your roster data frame contains a field named grade.")
    return(msg)
  }
  assert_that(has_grade(grade_col_test))
  
  #the roster grade field is an integer vecotr
  grade_integer_test <- is.integer(roster$grade)
  
  #write a custom failure message to make the test more helpful
  grade_is_integer <- function(x) {x==TRUE}
  on_failure(grade_is_integer) <- function(call, env) {
    msg <- paste0(
      "Roster objects can only have integers for the GRADE field.\n",
      "If you have a weird representation of Kindergarten that is not\n",
      "being handled by the mapvizieR constructor function, try running\n",
      "prep_roster(your_roster,kinder_codes=c('your weird K code'))."
    )
    return(msg)
  }
  assert_that(grade_is_integer(grade_integer_test))
  
  
  #return the test result
  return(grade_col_test & grade_integer_test)
}
