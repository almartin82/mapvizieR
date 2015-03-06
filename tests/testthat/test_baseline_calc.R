context("baseline_calc tests")

#constants
mapvizieR_obj <- mapvizieR(
  cdf=ex_CombinedAssessmentResults, 
  roster=ex_CombinedStudentsBySchool
)

processed_cdf <- mapvizieR_obj[['cdf']]

studentids <- processed_cdf[with(processed_cdf, 
  map_year_academic==2013 & measurementscale=='Mathematics' & 
  fallwinterspring=='Fall' & grade==6), ]$studentid

test_that("baseline_calc behaves", {
  
  ex_baseline <- calc_baseline_detail(
    mapvizieR_obj = mapvizieR_obj,
    studentids = studentids,
    measurementscale = 'Reading',
    target_fws = 'Spring',
    target_academic_year = 2012,
    fallback_fws = 'Fall',
    fallback_academic_year = 2013
  )
    
  expect_equal(nrow(ex_baseline), 93)
  expect_equal(sum(ex_baseline$baseline_RIT), 19342)
})


test_that("baseline_calc with no fallback", {
  
  no_fallback <- calc_baseline_detail(
    mapvizieR_obj = mapvizieR_obj,
    studentids = studentids,
    measurementscale = 'Reading',
    target_fws = 'Spring',
    target_academic_year = 2012  
  )
    
  expect_equal(nrow(no_fallback), 93)
  expect_equal(sum(no_fallback$baseline_RIT, na.rm=TRUE), 7745)
})

