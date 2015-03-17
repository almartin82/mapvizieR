#' @title populate_constants
#' 
#' @description global variables to make tests run faster.  this might be a bad idea.

populate_constants <- function() {

  mapviz <<- mapvizieR(cdf = ex_CombinedAssessmentResults, 
    roster = ex_CombinedStudentsBySchool)
  cdf <<- mapviz[['cdf']]
  roster <<- mapviz[['roster']]
  growth_df <<- mapviz[['growth_df']]
  
  #intermediate
  prepped_cdf <<- prep_cdf_long(ex_CombinedAssessmentResults)
  #processed
  prepped_roster <<- prep_roster(ex_CombinedStudentsBySchool)
  prepped_cdf$grade <<- grade_levelify_cdf(prepped_cdf, prepped_roster)
  processed_cdf <<- process_cdf_long(prepped_cdf)

  #studentid vectors
  studentids_normal_use <<- cdf[with(cdf, 
    map_year_academic == 2013 & measurementscale == 'Mathematics' & 
    fallwinterspring == 'Fall' & grade == 6), ]$studentid
  studentids_random <<- sample(ex_CombinedStudentsBySchool$StudentID, 100) %>% 
      unique 
  studentids_subset <<- studentids <- cdf[with(cdf, 
    map_year_academic == 2013 & measurementscale == 'Mathematics' & 
    fallwinterspring == 'Fall'), ]$studentid
  studentids_hs <<- studentids <- cdf[with(cdf, 
    map_year_academic == 2013 & measurementscale == 'Mathematics' & 
    fallwinterspring == 'Fall' & grade %in% c(10,11)), ]$studentid
  studentids_gr11 <<- studentids <- cdf[with(cdf, 
    map_year_academic == 2013 & measurementscale == 'Mathematics' & 
    fallwinterspring == 'Fall' & grade == 11), ]$studentid

  mapviz_midyear <<- mapvizieR(
    cdf = ex_CombinedAssessmentResults[with(ex_CombinedAssessmentResults, 
      TermName != 'Spring 2013-2014'), ], 
    roster = ex_CombinedStudentsBySchool
  )
}


#' @title testing_constants
#' 
#' @description wrapper function that calls populate_constants if they aren't in the
#' environment 

testing_constants <- function() {
  if (!exists(c("mapviz", "cdf", "roster", "growth_df", 
      "prepped_cdf", "processed_cdf",
      "studentids_normal_use", "studentids_random", "studentids_subset"))) {
    populate_constants()
  } 
}
