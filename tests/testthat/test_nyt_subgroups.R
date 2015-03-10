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
  samp_nyt <- nyt_subgroups(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Reading',
    subgroup_cols = c('starting_quartile', 'studentgender'),
    pretty_names = c('Starting Quartile', 'Gender'),
    start_fws = 'Fall',
    start_academic_year = 2013,
    end_fws = 'Spring',
    end_academic_year = 2013
  )
  
  expect_is(samp_nyt, 'arrange')
  expect_is(samp_nyt, 'ggplot')
  expect_is(samp_nyt, 'gTree')
  expect_is(samp_nyt, 'grob')
  expect_is(samp_nyt, 'gDesc')
  
  expect_equal(length(samp_nyt), 5)
  expect_equal(names(samp_nyt), c("name", "gp", "vp", "children", "childrenOrder"))
  
  expect_equal(dimnames(summary(samp_nyt[[4]]))[[2]], c("Length", "Class", "Mode"))
  expect_equal(unname(summary(samp_nyt[[4]])[1, ]), c("6", "frame", "list"))
})




test_that("fuzz test nyt_subgroups plot", {
 
})
