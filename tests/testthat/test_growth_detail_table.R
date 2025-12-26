context("growth detail table tests")

test_that("stu_growth_detail should return valid data frame", {

  ex <- stu_growth_detail(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Mathematics',
    entry_grade_seasons = c(-0.8, 5.2)
  )
  
  expect_s3_class(ex, 'data.frame')
  expect_s3_class(ex, 'tbl_df')
  expect_equal(
    ex$first_rit %>% sum(), 20271
  )
  
})

test_that("stu_growth_detail_table should return grob", {
  
  ex <- stu_growth_detail_table(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Mathematics',
    entry_grade_seasons = c(-0.8, 5.2)
  )
  
  expect_s3_class(ex, 'gtable')
  expect_s3_class(ex, 'grob')
  expect_equal(
    ex$layout$z %>% sum(), 220
  )
  
})