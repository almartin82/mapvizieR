#' @title generate_growth_df
#'
#' @description
#' \code{generate_growth_df} takes a CDF and given two seasons (start and end) saturates
#' all possible growth calculations for a student and returns a long data frame with the
#' results.
#'
#' @details 
#' This function returns a growth data frame, with one row per student per test per 
#' valid 'growth_window', such as 'Fall to Spring'. 
#' 
#' @param prepped_cdf a conforming prepped_cdf data frame
#' @param start_season the start of the growth window ("Fall", "Winter", or "Spring")
#' @param end_season the end of the growth window ("Fall", "Winter", or "Spring")
#' @param norm_df defaults to norms_students_2011.  if you have a conforming norms object,
#' you can use generate_growth_df to produce a growth data frame for those norms.
#' example usage: calculate college ready growth norms, and use generate_growth_df to see
#' if students met them.
#' @param include_unsanctioned_windows if TRUE, generate_growth_df will
#' return some additional growth windows like 'Spring to Winter', which aren't in the 
#' official norms (but might be useful for progress monitoring).
#' 
#' @return a data frame with all rows where the student had at least ONE matching 
#' test event (start or end)
#' 
#' @export

generate_growth_df <- function(
  prepped_cdf,
  start_season, 
  end_season,
  norm_df=norms_students_2011,
  include_unsanctioned_windows=FALSE
){  
  #input validation
  assert_that(
    is.data.frame(prepped_cdf),
    is.data.frame(norm_df),
    start_season %in% c("Fall", "Spring", "Winter"), 
    end_season %in% c("Fall", "Spring", "Winter"),
    is.logical(include_unsanctioned_windows)
  )
  check_cdf_long(prepped_cdf)
  
  #generate a scaffold of students/terms/windows
  

}



#' @title student_scaffold
#' 
#' @description which student/test/season rows have valid data?
#' 
#' @param processed_cdf a conforming processed_cdf data frame
#' @param start_season the start of the growth window ("Fall", "Winter", or "Spring")
#' @param end_season the end of the growth window ("Fall", "Winter", or "Spring")
#' @param year_offset start_year + ? = end_year.  if same academic_year (eg fall to spring)
#' this is 0  if spring to spring, this is 1
#' 
#' @return a data frame to pass back generate_growth_df that has kids, and the relevant 
#' student/test/seasons to calculate growth records on

student_scaffold <- function(
  processed_cdf,
  start_season,
  end_season,
  year_offset
) {
  #input validation
  assert_that(
    is.data.frame(processed_cdf),
    start_season %in% c("Fall", "Spring", "Winter"), 
    end_season %in% c("Fall", "Spring", "Winter"),
    check_processed_cdf(processed_cdf)$boolean
  )
  
  #make a simplified df
  cols <- c("studentid", "testid", "measurementscale",
    "map_year_academic", "fallwinterspring", "grade", "grade_level_season"           
  )
  simple <- processed_cdf[ ,cols]
  
  #grab all the unique start values
  start <- simple[simple$fallwinterspring==start_season, ]
  
}
