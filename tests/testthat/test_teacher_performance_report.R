context("teacher performance report tests")

#make sure that constants used below exist
testing_constants()

test_that("teacher performance report should return ggplot object", {  
  
  tpu_test <- teacher_performance_update(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Reading',
    start_fws = 'Fall',
    start_academic_year = 2013,
    end_fws = 'Spring',
    end_academic_year = 2013
  )

  expect_equal(length(tpu_test), 3)
  expect_true("gtable" %in% class(tpu_test))  
})  
