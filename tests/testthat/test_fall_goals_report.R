context("fall goals report tests")

#make sure that constants used below exist
testing_constants()

test_that("fall goals report should return list of plots", {  
  
  fg_test <- fall_goals_report(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Reading',
    context = '6th grade Mt. Bachelor | Reading', 
    start_fws = 'Spring',
    start_year_offset = -1,
    end_fws = 'Spring',
    end_academic_year = 2013
  )
  expect_equal(length(fg_test), 3)
  expect_true("list" %in% class(fg_test))
  expect_true("grob" %in% class(fg_test[[2]]))
})  
