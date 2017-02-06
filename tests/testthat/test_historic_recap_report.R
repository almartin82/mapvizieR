context("historic_recap_report tests")


test_that("historic recap report produces valid plot", {
  
  p <- historic_recap_report(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Mathematics',
    entry_grade_seasons = c(-0.8, 5.2),
    first_and_spring_only = FALSE
  ) 
  
  expect_is(p, 'grob')
  expect_is(p, 'gtable')
  expect_equal(length(p), 2)
  
  p <- historic_recap_report(
    mapvizieR_obj = mapviz,
    studentids = studentids_ms,
    measurementscale = 'Mathematics',
    entry_grade_seasons = c(-0.8, 5.2),
    first_and_spring_only = FALSE
  ) 
  
  expect_is(p, 'grob')
  expect_is(p, 'gtable')
})

test_that("historic recap report detail produces valid plot", {
  
  p <- historic_recap_report_detail(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Mathematics',
    subgroup_cols = c('studentgender'),
    pretty_names = c('Gender'),
    start_fws = c('Fall'),
    start_year_offset = c(0),
    end_fws = c('Spring'),
    end_academic_year = c(2013),
    entry_grade_seasons = c(-0.8, 5.2)
  ) 
  
  expect_is(p, 'grob')
  expect_is(p, 'gtable')
  expect_equal(length(p), 6)
})