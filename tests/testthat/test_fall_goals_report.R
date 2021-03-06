context("fall goals report tests")

test_that("fall goals report should return list of plots", {  
  
  fg_test <- fall_goals_report(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Reading',
    context = '6th grade Mt. Bachelor | Reading', 
    start_fws = 'Spring',
    start_year_offset = -1,
    end_fws = 'Spring',
    end_academic_year = 2013,
    exclude_prior_year_holdover = FALSE,
    detail_academic_year = 2013,
    goal_cgp = 80
  )
  expect_equal(length(fg_test), 1)
  expect_true("list" %in% class(fg_test))
  expect_true("grob" %in% class(fg_test[[1]]))
  
})  

test_that("fall goals data table returns tableGrob", {
  
  fgt_test <- fall_goals_data_table(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Mathematics', 
    start_fws = 'Spring',
    start_year_offset = -1,
    end_fws = 'Spring',
    end_academic_year = 2013,
    end_grade = 6
  )
  
  expect_is(fgt_test, 'gtable')
  expect_is(fgt_test, 'grob')
  
  fgt_test %>% plot()
})


test_that("options on fall goals component plots", {
  
  ex_table <- fall_goals_data_table(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Reading',
    start_fws = 'Spring',
    start_year_offset = -1,
    end_fws = 'Spring',
    end_academic_year = 2013,
    end_grade = 6,
    start_fws_prefer = NA, 
    calc_for = 85,
    output = 'both',
    font_size = 34
  )
  
  expect_is(ex_table, 'gtable')
  expect_is(ex_table, 'grob')
  
})


test_that("options on fall goals report", {  
  
  fg_test <- fall_goals_report(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Reading',
    context = '6th grade Mt. Bachelor | Reading', 
    start_fws = 'Spring',
    start_year_offset = -1,
    end_fws = 'Spring',
    end_academic_year = 2013,
    exclude_prior_year_holdover = TRUE,
    detail_academic_year = 2013,
    goal_cgp = 80
  )
  expect_equal(length(fg_test), 1)
  expect_true("list" %in% class(fg_test))
  expect_true("grob" %in% class(fg_test[[1]]))
  
})  


test_that("fall goals page 1", {  
  
  fg_test <- fall_goals_report_p1(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Mathematics',
    context = '6th grade Mt. Bachelor | Mathematics', 
    start_fws = 'Spring',
    start_year_offset = -1,
    end_fws = 'Spring',
    end_academic_year = 2013,
    exclude_prior_year_holdover = FALSE,
    detail_academic_year = 2013,
    goal_cgp = 80,
    entry_grade_seasons = c(-0.8, 5.2)
  )
  expect_equal(length(fg_test), 5)
  expect_true("grob" %in% class(fg_test))
  expect_true("gtable" %in% class(fg_test))
  
})