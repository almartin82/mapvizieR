context("schambach_table tests")

test_that("schambach_table produces proper table dimensions", {
  
  # one cut
  samp_dflist <- schambach_table_1d(
    mapvizieR_obj = mapviz,
    measurementscale_in = 'Reading',
    studentids = c(paste0('F0800000', 1:9), paste0('F080000', 10:99)),
    subgroup_cols = c('schoolname'),
    pretty_names = c('School Name'),
    start_fws = 'Fall',
    start_academic_year = 2013,
    end_fws = 'Spring',
    end_academic_year = 2013,
    complete_obsv = FALSE
  )
  
  expect_equal(length(samp_dflist), 1)
  expect_equal(dim(samp_dflist[[1]]), c(5, 8))
  
  # three cuts
  samp_dflist <- schambach_table_1d(
    mapvizieR_obj = mapviz,
    measurementscale_in = 'Reading',
    studentids = c(paste0('F0800000', 1:9), paste0('F080000', 10:99)),
    subgroup_cols = c('schoolname', 'studentgender', 'studentethnicgroup'),
    pretty_names = c('School Name', 'Gender', 'Ethnicity'),
    start_fws = 'Fall',
    start_academic_year = 2013,
    end_fws = 'Spring',
    end_academic_year = 2013,
    complete_obsv = FALSE
  )
  
  expect_equal(length(samp_dflist), 3)
  expect_equal(dim(samp_dflist[[1]]), c(5, 8))
  expect_equal(dim(samp_dflist[[2]]), c(4, 8))
  expect_equal(dim(samp_dflist[[3]]), c(7, 8))
  
  
  # complete_obsv = TRUE
  samp_dflist <- schambach_table_1d(
    mapvizieR_obj = mapviz,
    measurementscale_in = 'Reading',
    studentids = c(paste0('F0800000', 1:9), paste0('F080000', 10:99)),
    subgroup_cols = c('schoolname'),
    pretty_names = c('School Name'),
    start_fws = 'Fall',
    start_academic_year = 2013,
    end_fws = 'Spring',
    end_academic_year = 2013,
    complete_obsv = TRUE
  )
  
  expect_equal(length(samp_dflist), 1)
  expect_equal(dim(samp_dflist[[1]]), c(5, 8))
  
})