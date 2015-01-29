context("Galloping elephants tests")

#constants
mapviz <- mapvizieR(raw_cdf=ex_CombinedAssessmentResults, raw_roster=ex_CombinedStudentsBySchool)
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

test_that("galloping_elephants errors when handed an improper mapviz object", {
  expect_error(
    galloping_elephants(processed_cdf, studentids), 
    "The object you passed is not a conforming mapvizieR object"
  )  
})


test_that("galloping_elephants produces proper plot with a grade level of kids", {
    
  valid_grades <- c(c(-0.8,4.2), seq(0:13))
  
  n_rows <- mapviz$cdf %>% 
    filter(studentid %in% studentids_normal_use,
           grade %in% valid_grades |
           map_year_academic==2014) %>%
    nrow
  
  p <- galloping_elephants(mapviz, studentids_normal_use)
  
  p_build <- ggplot_build(p)
  
  expect_true(is.ggplot(p))
  expect_equal(nrow(p_build$plot$data), n_rows)
  
})



test_that("galloping_elephants returns expected data with a nonsense grouping of kids", {
    
  valid_grades <- c(c(-0.8,4.2), seq(0:13))
    
  p <- galloping_elephants(mapviz, studentids_subset)
  
  p_build <- ggplot_build(p)
  
  expect_true(is.ggplot(p))
  expect_equal(nrow(p_build$plot$data), 8425)
  
})
