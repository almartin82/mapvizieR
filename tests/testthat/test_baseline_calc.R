context("baseline_calc tests")

#make sure that constants used below exist
testing_constants()

test_that("baseline_calc behaves", {
  
  ex_baseline <- calc_baseline_detail(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Reading',
    primary_fws = 'Spring',
    primary_academic_year = 2012,
    fallback_fws = 'Fall',
    fallback_academic_year = 2013
  )
    
  expect_equal(nrow(ex_baseline), 93)
  expect_equal(sum(ex_baseline$baseline_RIT), 19342)
})


test_that("baseline_calc with no fallback", {
  
  no_fallback <- calc_baseline_detail(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Reading',
    primary_fws = 'Spring',
    primary_academic_year = 2012  
  )
    
  expect_equal(nrow(no_fallback), 93)
  expect_equal(sum(no_fallback$baseline_RIT, na.rm=TRUE), 7745)
})

