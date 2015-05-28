context("cgp_prep tests")

#make sure that constants used below exist
testing_constants()

ex_target_rit <- calc_cgp(
    measurementscale = 'Reading', grade = 2, 
    growth_window = 'Fall to Spring', baseline_avg_rit = 173
  )[['targets']]

ex_target_npr <- calc_cgp(
    measurementscale = 'Reading', grade = 2, 
    growth_window = 'Fall to Spring', baseline_avg_npr = 43
  )[['targets']]


test_that("calc_cgp tests", {

  expect_equal(sum(ex_target_rit$growth_target),  1509.75)
  expect_equal(sum(ex_target_npr$growth_target), 1160.28)

  expect_equal(nrow(ex_target_rit), 99)
  expect_equal(nrow(ex_target_npr), 99)

  diff_params <- calc_cgp(measurementscale = 'Reading', grade = 2, 
    growth_window = 'Fall to Spring', baseline_avg_rit = 173, calc_for = c(50:60)
  )[['targets']]
      
  #addl params
  expect_equal(round(sum(diff_params$growth_target), 2), 171.40  )
    
  low_npr_ex <- calc_cgp(measurementscale = 'Reading', grade = 2, 
    growth_window = 'Fall to Spring', baseline_avg_rit = 133
  )[['targets']]
  
  expect_equal(as.character(low_npr_ex$measured_in), c(rep("NPR", 99)))
  expect_equal(sum(low_npr_ex$growth_target),  929.1)
  
})


test_that("determine_cgp_method tests", {

  #cgp_nearest_lookup
  expect_equal(
    determine_cgp_method('Mathematics', 5, 'Fall to Spring', 
      206, 10, sch_growth_norms_2012),
    "lookup"
  )

  #cgp_nearest_lookup for science
  expect_equal(
    determine_cgp_method('General Science', 5, 'Fall to Spring'
      ,206, 10, sch_growth_norms_2012),
    "generalization"
  )
  
  #cgp_generalization when outside of rit difference tolerance  
  expect_equal(
    determine_cgp_method('Mathematics', 5, 'Fall to Spring'
      ,178, 10, sch_growth_norms_2012),
    "generalization"
  )

})


test_that("calc_cgp should fail given parameters out of range", {

  expect_error(
    calc_cgp(measurementscale = 'Reading', grade = 2, growth_window = 'Fall to Spring')
  )
  
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

    
  npr_ex <- calc_cgp(
    measurementscale = 'Mathematics', 
    grade = 8, 
    growth_window = 'Spring to Spring', 
    baseline_avg_npr = 47,
    ending_avg_npr = 62
  )[['results']]
  
  expect_equal(rit_ex, 57.4245, tolerance = 0.01)
  expect_equal(npr_ex, 97.0164, tolerance = 0.01)
  
})


test_that("calc_cgp results handle missing data", {
  
  rit_ex <- calc_cgp(
    measurementscale = 'Mathematics', 
    grade = 8, 
    growth_window = 'Spring to Spring', 
    baseline_avg_rit = 226.7
  )[['results']]

    
  npr_ex <- calc_cgp(
    measurementscale = 'Mathematics', 
    grade = 8, 
    growth_window = 'Spring to Spring', 
    baseline_avg_npr = 47
  )[['results']]
  
  expect_true(is.na(rit_ex))
  expect_true(is.na(npr_ex))
  
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
  expect_equal(ex_cgp$avg_npr_change, -5.913978, tolerance = 0.01)
  expect_equal(ex_cgp$n, 93)
  expect_equal(ex_cgp$cgp, 60.95068, tolerance = 0.01)
  
})