#' @title grade_levelify_cdf
#'
#' @description
#' \code{grade_levelify_cdf} adds a student's grade level at test time to
#' the cdf.  grade level is required for a variety of growth calculations.
#'
#' @param prepped_cdf a cdf file that passes the checks in \code{check_cdf_long}
#' @param roster a roster that passes the checks in \code{check_roster}
#'
#' @return a vector of grades
#' 
#' @export

grade_levelify_cdf <- function(prepped_cdf, roster) {
  
  slim_roster <- unique(roster[, c('studentid', 'termname', 'grade')])
  #first match on a student's EXACT termname
  matched_cdf <- left_join(prepped_cdf, slim_roster, by=c('studentid', 'termname'))
  
  exact_count <- nrow(!is.na(matched_cdf$grade))
  
  #if there are still unmatched students, attempt to match on map_year_academic
  if (nrow(matched_cdf[is.na(matched_cdf$grade), ]) > 0) {
    
    slim_roster <- unique(roster[, c('studentid', 'map_year_academic', 'grade')])
    
    secondary_match <- left_join(
      prepped_cdf, 
      slim_roster, by=c('studentid', 'map_year_academic') 
    )
    
    matched_cdf$grade <- ifelse(
      is.na(matched_cdf$grade), secondary_match$grade, matched_cdf$grade
    )
  } 
  
  return(matched_cdf$grade)
}

#' @title match assessment results with students by school roster. 
#'
#' @description
#' \code{cdf_roster_match} performs an inner join on a prepped, long cdf (Assesment Results)
#' a prepped long roster (i.e. StudentsBySchool).  
#'
#' @param assessment_results a cdf file that passes the checks in \code{\link{check_cdf_long}}
#' @param roster a roster that passes the checks in \code{\link{check_roster}}
#'
#' @return a merged data frame with \code{nrow(prepped_cdf)}
#' 
#' @export

cdf_roster_match <- function(assessment_results, roster) {
  # Validation
  assert_that(check_cdf_long(assessment_results)$boolean, 
              check_roster(roster)$boolean
  )
  
  # inner join of roster and assessment results by id, subject, and term name
  matched_df <-  dplyr::inner_join(roster, 
                                   assessment_results %>% filter(growthmeasureyn=TRUE),
                                   by=c("studentid", "termname", "schoolname")
  ) %>%
    select(-ends_with(".y")) %>% # drop repeated columns
    as.data.frame
  
  # drop .x join artifact from colun names (we dropped .y in select above )
  names(matched_df)<-gsub("(.+)(\\.x)", "\\1", names(matched_df))
  
  
  #check that number of rows of assessment_results = nrow of matched_df
  input_rows <- nrow(assessment_results)
  output_rows <- nrow(matched_df)
  if(input_rows!=output_rows){
    cdf_name<-substitute(assessment_results)
    msg <- paste0("The number of rows in ", cdf_name, " is ", input_rows, 
                  ", while the number of rows in the matched data frame\n",
                  "returned by this function is ", output_rows, ".\n\n",
                  "You might want to check your data.")
    warning(msg)
  }
  
  #return 
  matched_df
}
