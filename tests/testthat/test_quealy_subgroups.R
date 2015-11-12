context("quealy_subgroups tests")

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
  
  expect_is(samp_nyt, 'gtable')
  expect_is(samp_nyt, 'grob')
  expect_is(samp_nyt, 'gDesc')
  
  expect_equal(length(samp_nyt), 2)
  expect_equal(
    names(samp_nyt), 
    c("grobs", "layout", "widths", "heights", "respect",
      "rownames", "colnames", "name", "gp", "vp")
  )
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
  
  expect_is(samp_nyt, 'gtable')
  expect_is(samp_nyt, 'grob')
  expect_is(samp_nyt, 'gDesc')
  
  expect_equal(length(samp_nyt), 2)
  expect_equal(names(samp_nyt), c("grobs", "layout",
                                  "widths", "heights", "respect",
                                  "rownames", 
                                  "colnames", "name",
                                  "gp", "vp"))
  
  #expect_equal(dimnames(summary(samp_nyt[[4]]))[[2]], c("Length", "Class", "Mode"))
  #expect_equal(unname(summary(samp_nyt[[4]])[1, ]), c("6", "frame", "list"))
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
  
  expect_is(samp_nyt, 'gtable')
  expect_is(samp_nyt, 'grob')
  expect_is(samp_nyt, 'gDesc')
  
  expect_equal(length(samp_nyt), 3)
  expect_equal(names(samp_nyt), c("grobs", "layout",
                                  "widths", "heights", "respect",
                                  "rownames", 
                                  "colnames", "name",
                                  "gp", "vp"))
  
  #expect_equal(dimnames(summary(samp_nyt[[4]]))[[2]], c("Length", "Class", "Mode"))
  #expect_equal(unname(summary(samp_nyt[[4]])[1, ]), c("6", "frame", "list"))
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
  
  expect_is(samp_nyt, 'gtable')
  expect_is(samp_nyt, 'grob')
  expect_is(samp_nyt, 'gDesc')
  
  expect_equal(length(samp_nyt), 3)
  expect_equal(names(samp_nyt), c("grobs", "layout",
                                  "widths", "heights", "respect",
                                  "rownames", 
                                  "colnames", "name",
                                  "gp", "vp"))
  
  #expect_equal(dimnames(summary(samp_nyt[[4]]))[[2]], c("Length", "Class", "Mode"))
  #expect_equal(unname(summary(samp_nyt[[4]])[1, ]), c("6", "frame", "list"))
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

  expect_is(auto_growth, 'gtable')
  expect_is(auto_growth, 'grob')
  expect_is(auto_growth, 'gDesc')
  
  expect_equal(length(auto_growth), 3)
  expect_equal(names(auto_growth), c("grobs", "layout",
                                  "widths", "heights", "respect",
                                  "rownames", 
                                  "colnames", "name",
                                  "gp", "vp"))
  
  #expect_equal(dimnames(summary(auto_growth[[4]]))[[2]], c("Length", "Class", "Mode"))
  #expect_equal(unname(summary(auto_growth[[4]])[1, ]), c("6", "frame", "list"))
})


test_that("quealy_subgroups with starting_quartile magic subgroup", {
  
  magic_quartiles <- quealy_subgroups(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Reading',
    subgroup_cols = c('studentgender'),
    pretty_names = c('Gender'),
    magic_subgroups = c('starting_quartile'),
    start_fws = 'Fall',
    start_year_offset = 0,
    end_fws = 'Spring',
    end_academic_year = 2013,
    complete_obsv = TRUE
  )
  
  expect_is(magic_quartiles, 'gtable')
  expect_is(magic_quartiles, 'grob')
  expect_is(magic_quartiles, 'gDesc')
  
  expect_equal(length(magic_quartiles), 3)
  expect_equal(
    names(magic_quartiles), 
    c("grobs", "layout", "widths", "heights", "respect",
      "rownames", "colnames", "name", "gp", "vp")
    )
})


test_that("quealy_subgroups with zero-length student df", {
  
  expect_error(
    quealy_subgroups(
      mapvizieR_obj = mapviz,
      studentids = mapviz$roster %>% 
        dplyr::filter(map_year_academic == 2013 & grade == 0) %>% 
        dplyr::select(studentid) %>% unlist() %>% unname(),
      measurementscale = 'General Science',
      subgroup_cols = c('studentgender'),
      pretty_names = c('Gender'),
      start_fws = 'Fall',
      start_year_offset = 0,
      end_fws = 'Spring',
      end_academic_year = 2013,
      complete_obsv = TRUE
    ),
    "no matching students for the specified subject/terms."
  )
})


test_that("quealy_subgroups with small_n filter", {
  
  small_n <- quealy_subgroups(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Reading',
    subgroup_cols = c('studentethnicgroup'),
    pretty_names = c('Ethnicity'),
    start_fws = 'Fall',
    start_year_offset = 0,
    end_fws = 'Spring',
    end_academic_year = 2013,
    complete_obsv = TRUE,
    small_n_cutoff = 0.2
  )
  
  expect_is(small_n, 'gtable')
  expect_is(small_n, 'grob')
  expect_is(small_n, 'gDesc')
  
  expect_equal(length(small_n), 2)
  expect_equal(
    names(small_n), 
    c("grobs", "layout", "widths", "heights", "respect",
      "rownames", "colnames", "name", "gp", "vp")
  )
})


test_that("quealy_subgroups with auto growth window", {
  
  auto_window <- quealy_subgroups(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Reading',
    subgroup_cols = c('studentethnicgroup'),
    pretty_names = c('Ethnicity'),
    start_fws = c('Spring', 'Fall'),
    start_year_offset = c(-1, 0),
    end_fws = 'Spring',
    end_academic_year = 2013,
    start_fws_prefer = 'Spring',
    complete_obsv = TRUE,
    small_n_cutoff = 0.2
  )
  
  expect_is(auto_window, 'gtable')
  expect_is(auto_window, 'grob')
  expect_is(auto_window, 'gDesc')
  
  expect_equal(length(auto_window), 2)
  expect_equal(
    names(auto_window), 
    c("grobs", "layout", "widths", "heights", "respect",
      "rownames", "colnames", "name", "gp", "vp")
    )
})

