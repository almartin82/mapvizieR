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
  expect_equal(
    p$grobs[[2]][[1]][[2]][[1]][[11]]$children$axis$grobs[[2]]$children[[1]]$x,
    structure(
      c(0.850649350649351, 0.928571428571429, 0.590909090909091, 
        0.668831168831169, 0.331168831168831, 0.409090909090909, 0.0714285714285713, 
        0.149350649350649), unit = "native", valid.unit = 4L, class = "unit")
  )
  
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
  expect_equal(
    p[[1]][[6]] %>% names(),
    c("grobs", "layout", "widths", "heights", "respect", "rownames", 
      "colnames", "name", "gp", "vp")
  )
})