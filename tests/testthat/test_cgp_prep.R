context("cgp_prep tests")

#make sure that constants used below exist
testing_constants()

ex_target_rit <- calc_cgp(
    measurementscale = 'Reading', 
    end_grade = 2, 
    growth_window = 'Fall to Spring', 
    baseline_avg_rit = 173,
    norms = 2012
  )[['targets']]


test_that("calc_cgp tests with 2012 norms", {

  expect_equal(sum(ex_target_rit$growth_target),  1509.75)

  expect_equal(nrow(ex_target_rit), 99)

  diff_params <- calc_cgp(
    measurementscale = 'Reading', 
    end_grade = 2, 
    growth_window = 'Fall to Spring', 
    baseline_avg_rit = 173, 
    calc_for = c(50:60),
    norms = 2012
  )[['targets']]
      
  #addl params
  expect_equal(sum(diff_params$growth_target), 171.3971, tolerance = .01)
    
  low_npr_ex <- calc_cgp(measurementscale = 'Reading', end_grade = 2, 
    growth_window = 'Fall to Spring', baseline_avg_rit = 133
  )[['targets']]
  
  expect_equal(as.character(low_npr_ex$measured_in), c(rep("RIT", 99)))
  expect_equal(sum(low_npr_ex$growth_target),  1800.81)
  
})


test_that("calc_cgp should fail given parameters out of range", {

  expect_error(
    calc_cgp(
      measurementscale = 'Reading', 
      end_grade = 2, growth_window = 'Fall to Spring', 
      baseline_avg_rit = 173, calc_for = c(-10:2)
    )
  )
  
})


test_that("calc_cgp results with 2012 norms", {
  
  rit_ex <- calc_cgp(
    measurementscale = 'Mathematics', 
    end_grade = 8, 
    growth_window = 'Spring to Spring', 
    baseline_avg_rit = 226.7,
    ending_avg_rit = 233,
    norms = 2012
  )[['results']]

  expect_equal(rit_ex,  57.4245, tolerance = 0.01)
})


test_that("calc_cgp results handle missing data", {
  
  rit_ex <- calc_cgp(
    measurementscale = 'Mathematics', 
    end_grade = 8, 
    growth_window = 'Spring to Spring', 
    baseline_avg_rit = 226.7
  )[['results']]

  expect_true(is.na(rit_ex))
})


test_that("mapviz_cgp calculates cgp for sample data with 2012 norms", {
  
  ex_cgp <- mapviz_cgp(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Reading',
    start_fws = 'Fall',
    start_academic_year = 2013,
    end_fws = 'Spring',
    end_academic_year = 2013,
    norms = 2012
  )
  
  expect_equal(ex_cgp$avg_start_rit, 207.3226, tolerance = 0.01)
  expect_equal(ex_cgp$avg_end_rit, 213.8065, tolerance = 0.01)
  expect_equal(ex_cgp$avg_rit_change, 6.483871, tolerance = 0.01)
  expect_equal(ex_cgp$avg_start_npr, 41.63441, tolerance = 0.01)
  expect_equal(ex_cgp$avg_end_npr, 45.93548, tolerance = 0.01)
  expect_equal(ex_cgp$avg_npr_change, 4.301075, tolerance = 0.01)
  expect_equal(ex_cgp$n, 93)
  expect_equal(ex_cgp$cgp, 60.95068, tolerance = 0.01)
  
})


test_that("calc_cgp is correct from NWEA lookups with 2012 norms", {

  m5ss_results_199 <- c()
  for (i in c(4:16)) {
    m5ss <- calc_cgp(
      measurementscale = 'Mathematics', end_grade = 5, 
      growth_window = 'Spring to Spring', 
      baseline_avg_rit = 199, ending_avg_rit = 199 + i,
      norms = 2012
    )[['results']] 
    
    m5ss_results_199 <- c(m5ss_results_199, m5ss)
  }

  diffs <- m5ss_results_199 - c(1, 3, 7, 13, 23, 37, 52, 67, 80, 89, 95, 98, 99)
  expect_true(all(diffs < 3))
  
  m5ss_results_205 <- c()
  for (i in c(3:15)) {
    m5ss <- calc_cgp(
      measurementscale = 'Mathematics', end_grade = 5, 
      growth_window = 'Spring to Spring', 
      baseline_avg_rit = 205, ending_avg_rit = 205 + i,
      norms = 2012
    )[['results']] 
    
    m5ss_results_205 <- c(m5ss_results_205, m5ss)
  }

  diffs <- m5ss_results_205 - c(1, 2, 4, 10, 19, 31, 47, 63, 77, 87, 94, 97, 99)
  expect_true(all(diffs < 1))

})


test_that("RIT_to_npr and npr_to_RIT", {

  #2015 norms
  expect_equal(rit_to_npr("Mathematics", 5, 'Fall', 219), 70)
  expect_equal(rit_to_npr("Mathematics", 5, 'Fall', 230), 90)
  
  expect_equal(npr_to_rit("Mathematics", 5, 'Fall', 70), 219)
  expect_equal(npr_to_rit("Mathematics", 5, 'Fall', 90), 230)
  
  #2011 norms
  expect_equal(rit_to_npr("Mathematics", 5, 'Fall', 219, norms = 2011), 67)
  expect_equal(rit_to_npr("Mathematics", 5, 'Fall', 240, norms = 2011), 97)
  
  expect_equal(npr_to_rit("Mathematics", 5, 'Fall', 67, norms = 2011), 219)
  expect_equal(npr_to_rit("Mathematics", 5, 'Fall', 97, norms = 2011), 240)

})

test_that("one_cgp_step accurate with 2012 norms", {
  ex <- one_cgp_step(
    'Reading', 200, 5, 59, 'Fall to Spring', 2012
  )
  expect_equal(ex, 8.02, tolerance = .01)

  ex <- one_cgp_step(
    'Reading', 203, 4, 84, 'Spring to Spring', 2012
  )
  expect_equal(ex, 9.02, tolerance = .01)
  
})


test_that("mapviz cgp targets correctly handles composite baseline, 2012 norms", {  
  
  ex <- mapviz_cgp_targets(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Mathematics',
    start_fws = c('Spring', 'Fall'),
    start_year_offset = c(-1, 0),
    end_fws = 'Spring',
    end_academic_year = 2013,
    end_grade = 6,
    start_fws_prefer = 'Spring',
    norms = 2012
  )
  
  expect_is(ex, 'data.frame')
  expect_equal(ex$growth_target %>% sum(), 628.65, tolerance = 0.1)

})


test_that("mapviz cgp targets correctly handles explicit baseline, 2012 norms", {  
  
  ex <- mapviz_cgp_targets(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Mathematics',
    start_fws = 'Fall',
    start_year_offset = 0,
    end_fws = 'Spring',
    end_academic_year = 2013,
    end_grade = 6,
    norms = 2012
  )
  
  expect_is(ex, 'data.frame')
  expect_equal(ex$growth_target %>% sum(), 762.3, tolerance = 0.1)
  
})
