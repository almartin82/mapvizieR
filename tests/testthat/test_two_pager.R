context("two-pager report tests")

#make sure that constants used below exist
testing_constants()

test_that("two-pager report should return ggplot object", {  
  tp_test <- two_pager(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Reading',
    start_fws = 'Fall',
    start_academic_year = 2013,
    end_fws = 'Spring',
    end_academic_year = 2013,
    detail_academic_year = 2013
  )  
  expect_equal(length(tp_test), 5)
  expect_true("ggplot" %in% class(tp_test))  
})  
