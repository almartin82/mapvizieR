context("cgp_prep tests")

#make sure that constants used below exist
testing_constants()

ex_target_rit <- calc_cgp(
    measurementscale = 'Reading', 
    grade = 2, 
    growth_window = 'Fall to Spring', 
    baseline_avg_rit = 173
  )[['targets']]


test_that("calc_cgp tests", {

  expect_equal(sum(ex_target_rit$growth_target),  1645.38)

  expect_equal(nrow(ex_target_rit), 99)

  diff_params <- calc_cgp(
    measurementscale = 'Reading', 
    grade = 2, 
    growth_window = 'Fall to Spring', 
    baseline_avg_rit = 173, 
    calc_for = c(50:60)
  )[['targets']]
      
  #addl params
  expect_equal(sum(diff_params$growth_target), 186.2828, tolerance = .01)
    
  low_npr_ex <- calc_cgp(measurementscale = 'Reading', grade = 2, 
    growth_window = 'Fall to Spring', baseline_avg_rit = 133
  )[['targets']]
  
  expect_equal(as.character(low_npr_ex$measured_in), c(rep("RIT", 99)))
  expect_equal(sum(low_npr_ex$growth_target),  2064.15)
  
})


test_that("calc_cgp should fail given parameters out of range", {

  expect_error(
    calc_cgp(measurementscale = 'Reading', grade = 2, growth_window = 'Fall to Spring', 
      baseline_avg_rit = 173, calc_for = c(-10:2)
    )
  )
  
})


test_that("calc_cgp results", {
  
  rit_ex <- calc_cgp(
    measurementscale = 'Mathematics', 
    grade = 8, 
    growth_window = 'Spring to Spring', 
    baseline_avg_rit = 226.7,
    ending_avg_rit = 233
  )[['results']]

  expect_equal(rit_ex,  99.96545, tolerance = 0.01)
})


test_that("calc_cgp results handle missing data", {
  
  rit_ex <- calc_cgp(
    measurementscale = 'Mathematics', 
    grade = 8, 
    growth_window = 'Spring to Spring', 
    baseline_avg_rit = 226.7
  )[['results']]

  expect_true(is.na(rit_ex))
})


test_that("mapviz_cgp calculates cgp for sample data", {
  
  ex_cgp <- mapviz_cgp(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Reading',
    start_fws = 'Fall',
    start_academic_year = 2013,
    end_fws = 'Spring',
    end_academic_year = 2013
  )
  
  expect_equal(ex_cgp$avg_start_rit, 207.3226, tolerance = 0.01)
  expect_equal(ex_cgp$avg_end_rit, 213.8065, tolerance = 0.01)
  expect_equal(ex_cgp$avg_rit_change, 6.483871, tolerance = 0.01)
  expect_equal(ex_cgp$avg_start_npr, 38.62366, tolerance = 0.01)
  expect_equal(ex_cgp$avg_end_npr, 44.53763, tolerance = 0.01)
  expect_equal(ex_cgp$avg_npr_change, 5.913978, tolerance = 0.01)
  expect_equal(ex_cgp$n, 93)
  expect_equal(ex_cgp$cgp, 65.89149, tolerance = 0.01)
  
})