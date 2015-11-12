context("fall goals report tests")

test_that("fall goals report should return list of plots", {  
  
    fg_test <- fall_goals_report(
      mapvizieR_obj = mapviz,
      studentids = studentids_normal_use,
      measurementscale = 'Mathematics',
      context = '6th grade Mt. Bachelor | Reading', 
      start_fws = 'Spring',
      start_year_offset = -1,
      end_fws = 'Spring',
      end_academic_year = 2013,
      detail_academic_year = 2013,
      goal_cgp = 90
    )
    expect_equal(length(fg_test), 2)
    expect_true("list" %in% class(fg_test))
    expect_true("grob" %in% class(fg_test[[2]]))
    
    fg_test[[2]] %>% plot()
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
