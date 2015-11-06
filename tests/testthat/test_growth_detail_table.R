context("growth detail table tests")

#make sure that constants used below exist
testing_constants()

test_that("stu_growth_detail should return valid data frame", {

  ex <- stu_growth_detail(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Mathematics',
    entry_grade_seasons = c(-0.8, 5.2)
  )
  
  expect_is(ex, 'data.frame')
  expect_is(ex, 'tbl_df')
  expect_equal(
    ex$first_rit %>% sum(), 20186
  )
  
})

test_that("stu_growth_detail_table should return grob", {
  
  ex <- stu_growth_detail_table(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Mathematics',
    entry_grade_seasons = c(-0.8, 5.2)
  )
  
  expect_is(ex, 'gtable')
  expect_is(ex, 'grob')
  expect_equal(
    ex$layout$z %>% sum(), 220
  )
  
})