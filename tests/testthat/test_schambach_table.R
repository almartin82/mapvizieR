context("schambach_table tests")

#make sure that constants used below exist
testing_constants()

test_that("schambach_table produces proper table dimensions", {
  samp_dflist <- schambach_table_1d(mapvizieR_obj = mmapvizieR_obj,
                                measurementscale_is = 'Reading',
                                grade = 5,
                                subgroup_cols = c('end_schoolname'),
                                pretty_names = c('School Name'),
                                start_fws = 'Fall',
                                start_academic_year = 2013,
                                end_fws = 'Spring',
                                end_academic_year = 2013,
                                complete_obsv = FALSE
  )
  
  expect_equal(length(samp_dflist), 1)
  expect_equal(nrow(samp_dflist[[1]]), 3)
  expect_equal(ncol(samp_dflist[[1]]), 8)
  
  samp_df <- schambach_table_1d(mapvizieR_obj = mmapvizieR_obj,
                                measurementscale_is = 'Reading',
                                grade = 5,
                                subgroup_cols = c('end_schoolname','studentgender','studentethnicgroup'),
                                pretty_names = c('School Name','Gender','Ethnicity'),
                                start_fws = 'Fall',
                                start_academic_year = 2013,
                                end_fws = 'Spring',
                                end_academic_year = 2013,
                                complete_obsv = FALSE
  )
  
  expect_equal(length(samp_dflist), 3)
  expect_equal(nrow(samp_dflist[[1]]), 3)
  expect_equal(nrow(samp_dflist[[2]]), 3)
  expect_equal(nrow(samp_dflist[[3]]), 3)
  
  expect_equal(ncol(samp_dflist[[1]]), 8)
  expect_equal(ncol(samp_dflist[[2]]), 8)
  expect_equal(ncol(samp_dflist[[3]]), 8)
  
})