context("schambach_table tests")

#make sure that constants used below exist
testing_constants()

test_that("schambach_table produces proper table dimensions", {
  
  # one grade level, one cut
  samp_dflist <- schambach_table_1d(mapvizieR_obj = mapviz,
                                measurementscale_in = 'Reading',
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
  expect_equal(names(samp_dflist), 'school_name')
  expect_equal(dim(samp_dflist$school_name), c(3, 8))
  
  # one grade level, three cuts
  samp_dflist <- schambach_table_1d(mapvizieR_obj = mapviz,
                                measurementscale_in = 'Reading',
                                grade = 5,
                                subgroup_cols = c('end_schoolname', 'studentgender', 'studentethnicgroup'),
                                pretty_names = c('School Name', 'Gender', 'Ethnicity'),
                                start_fws = 'Fall',
                                start_academic_year = 2013,
                                end_fws = 'Spring',
                                end_academic_year = 2013,
                                complete_obsv = FALSE
  )
  
  expect_equal(length(samp_dflist), 3)
  expect_equal(names(samp_dflist), c('school_name', 'gender', 'ethnicity'))
  expect_equal(dim(samp_dflist$school_name), c(3, 8))
  expect_equal(dim(samp_dflist$gender), c(3, 8))
  expect_equal(dim(samp_dflist$ethnicity), c(6, 8))
  
  # three grade levels, three cuts
  samp_dflist <- schambach_table_1d(mapvizieR_obj = mapviz,
                                   measurementscale_in = 'Reading',
                                   grade = c(4:6),
                                   subgroup_cols = c('studentgender', 'studentethnicgroup'),
                                   pretty_names = c('Gender', 'Ethnicity'),
                                   start_fws = 'Fall',
                                   start_academic_year = 2013,
                                   end_fws = 'Spring',
                                   end_academic_year = 2013,
                                   complete_obsv = FALSE
  )
  
  expect_equal(length(samp_dflist), 3)
  expect_equal(names(samp_dflist), c('grade_4', 'grade_5', 'grade_6'))
  expect_equal(names(samp_dflist[[1]]), c('gender', 'ethnicity'))
  expect_equal(dim(samp_dflist$grade_4$gender), c(3, 8))
  expect_equal(dim(samp_dflist$grade_4$ethnicity), c(6, 8))
  
  #complete_obsv = TRUE
  samp_dflist <- schambach_table_1d(mapvizieR_obj = mapviz,
                                    measurementscale_in = 'Reading',
                                    grade = 5,
                                    subgroup_cols = c('end_schoolname'),
                                    pretty_names = c('School Name'),
                                    start_fws = 'Fall',
                                    start_academic_year = 2013,
                                    end_fws = 'Spring',
                                    end_academic_year = 2013,
                                    complete_obsv = TRUE
  )
  
  expect_equal(names(samp_dflist), 'school_name')
  expect_equal(dim(samp_dflist$school_name), c(3, 8))
  
})