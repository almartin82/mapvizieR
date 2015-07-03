context("quealy_subgroups tests")

#make sure that constants used below exist
testing_constants()

test_that("quealy_subgroups errors when handed an improper mapviz object", {
  expect_error(
    quealy_subgroups(processed_cdf, studentids), 
    "The object you passed is not a conforming mapvizieR object"
  )  
})


test_that("quealy_subgroups produces proper plot with a grade level of kids", {
  samp_nyt <- quealy_subgroups(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Reading',
    subgroup_cols = c('studentgender'),
    pretty_names = c('Gender'),
    start_fws = 'Fall',
    start_year_offset = 0,
    end_fws = 'Spring',
    end_academic_year = 2013
  )
  
  expect_is(samp_nyt, 'arrange')
  expect_is(samp_nyt, 'ggplot')
  expect_is(samp_nyt, 'gTree')
  expect_is(samp_nyt, 'grob')
  expect_is(samp_nyt, 'gDesc')
  
  expect_equal(length(samp_nyt), 5)
  expect_equal(names(samp_nyt), c("name", "gp", "vp", "children", "childrenOrder"))
  
  expect_equal(dimnames(summary(samp_nyt[[4]]))[[2]], c("Length", "Class", "Mode"))
  expect_equal(unname(summary(samp_nyt[[4]])[1, ]), c("6", "frame", "list"))
})


test_that("quealy_subgroups with complete_obsv and title", {
  samp_nyt <- quealy_subgroups(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Reading',
    subgroup_cols = c('studentethnicgroup', 'studentgender'),
    pretty_names = c('Ethnicity', 'Gender'),
    start_fws = 'Fall',
    start_year_offset = 0,
    end_fws = 'Spring',
    end_academic_year = 2013,
    complete_obsv = TRUE,
    report_title = "Reading Fall=Spring 2013"
  )
  
  expect_is(samp_nyt, 'arrange')
  expect_is(samp_nyt, 'ggplot')
  expect_is(samp_nyt, 'gTree')
  expect_is(samp_nyt, 'grob')
  expect_is(samp_nyt, 'gDesc')
  
  expect_equal(length(samp_nyt), 5)
  expect_equal(names(samp_nyt), c("name", "gp", "vp", "children", "childrenOrder"))
  
  expect_equal(dimnames(summary(samp_nyt[[4]]))[[2]], c("Length", "Class", "Mode"))
  expect_equal(unname(summary(samp_nyt[[4]])[1, ]), c("6", "frame", "list"))
})


test_that("quealy_subgroups with no CGP", {
samp_nyt <- quealy_subgroups(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Reading',
    subgroup_cols = c('studentethnicgroup', 'studentgender'),
    pretty_names = c('Ethnic Group', 'Gender'),
    start_fws = 'Winter',
    start_year_offset = 0,
    end_fws = 'Spring',
    end_academic_year = 2013,
    complete_obsv = TRUE
  )
  
  expect_is(samp_nyt, 'arrange')
  expect_is(samp_nyt, 'ggplot')
  expect_is(samp_nyt, 'gTree')
  expect_is(samp_nyt, 'grob')
  expect_is(samp_nyt, 'gDesc')
  
  expect_equal(length(samp_nyt), 5)
  expect_equal(names(samp_nyt), c("name", "gp", "vp", "children", "childrenOrder"))
  
  expect_equal(dimnames(summary(samp_nyt[[4]]))[[2]], c("Length", "Class", "Mode"))
  expect_equal(unname(summary(samp_nyt[[4]])[1, ]), c("6", "frame", "list"))
})


test_that("quealy_subgroups with no school growth study", {
  samp_nyt <- quealy_subgroups(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Reading',
    subgroup_cols = c('studentethnicgroup', 'studentgender'),
    pretty_names = c('Ethnic Group', 'Gender'),
    start_fws = 'Fall',
    start_year_offset = 0,
    end_fws = 'Winter',
    end_academic_year = 2013,
    complete_obsv = TRUE
  )
  
  expect_is(samp_nyt, 'arrange')
  expect_is(samp_nyt, 'ggplot')
  expect_is(samp_nyt, 'gTree')
  expect_is(samp_nyt, 'grob')
  expect_is(samp_nyt, 'gDesc')
  
  expect_equal(length(samp_nyt), 5)
  expect_equal(names(samp_nyt), c("name", "gp", "vp", "children", "childrenOrder"))
  
  expect_equal(dimnames(summary(samp_nyt[[4]]))[[2]], c("Length", "Class", "Mode"))
  expect_equal(unname(summary(samp_nyt[[4]])[1, ]), c("6", "frame", "list"))
})


test_that("quealy_subgroups with multiple growth windows", {
  
  auto_growth <- quealy_subgroups(
    mapvizieR_obj = mapviz,
    studentids = roster$studentid,
    measurementscale = 'Reading',
    subgroup_cols = c('grade', 'studentgender'),
    pretty_names = c('Grade', 'Gender'),
    start_fws = 'Fall',
    start_year_offset = 0,
    end_fws = 'Spring',
    end_academic_year = 2013,
    complete_obsv = TRUE
  )
})