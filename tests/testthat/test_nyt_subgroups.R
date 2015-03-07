context("nyt_subgroups tests")

#constants
mapviz <- mapvizieR(cdf=ex_CombinedAssessmentResults, roster=ex_CombinedStudentsBySchool)
processed_cdf <- mapviz[['cdf']]
growth_df <- mapviz[['growth_df']]

studentids_normal_use <- processed_cdf[with(processed_cdf, 
  map_year_academic==2013 & measurementscale=='Mathematics' & 
  fallwinterspring=='Fall' & grade==6), ]$studentid
studentids_random <- sample(ex_CombinedStudentsBySchool$StudentID, 100) %>% 
    unique 
studentids_subset <- studentids <- processed_cdf[with(processed_cdf, 
  map_year_academic==2013 & measurementscale=='Mathematics' & 
  fallwinterspring=='Fall'), ]$studentid

test_that("nyt_subgroups errors when handed an improper mapviz object", {
  expect_error(
    nyt_subgroups(processed_cdf, studentids), 
    "The object you passed is not a conforming mapvizieR object"
  )  
})


test_that("nyt_subgroups produces proper plot with a grade level of kids", {
      
})




test_that("fuzz test nyt_subgroups plot", {
 
})
