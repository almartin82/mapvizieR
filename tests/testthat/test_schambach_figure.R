context("schambach_figure tests")

test_that("schambach_figure should return grid object", {
    # grid.arrange may produce different output types in different gridExtra versions
    figs <- schambach_figure(
      mapvizieR_obj = mapviz,
      measurementscale_in = 'Reading',
      studentids_in = c(paste0('F0800000', 1:9), paste0('F080000', 10:99)),
      subgroup_cols = c('grade', 'studentgender', 'studentethnicgroup'),
      pretty_names = c('Grade', 'Gender', 'Ethnicity'),
      start_fws = 'Fall',
      start_academic_year = 2013,
      end_fws = 'Spring',
      end_academic_year = 2013
    )

  # Check that output is a valid grid object (gtable or grob)
  expect_true("grob" %in% class(figs) || "gtable" %in% class(figs))
  # Modern gridExtra returns gtable with gTree/gDesc classes
  expect_true(any(c("grob", "gtable", "gTree", "gDesc") %in% class(figs)))
}) 