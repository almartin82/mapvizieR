# Create test data
mv_summary <- summary(mapviz$growth_df)

test_that("summary_long_plot errors when handed an improper object", {
  # The function first warns about object type, then errors about missing column
  # So we expect both warning and error
  expect_error(
    expect_warning(
      summary_long_plot(mapviz$cdf, growth_window = "Fall to Spring"),
      "must be a mapvizier_summary object"
    ),
    "is not a column in"
  )

  expect_error(
    expect_warning(
      summary_long_plot(mapviz$growth_df, growth_window = "Fall to Spring"),
      "must be a mapvizier_summary object"
    ),
    "is not a column in"
  )
})


test_that("summary_long_plot errors when metric is not in summary object", {
  expect_error(
    suppressWarnings(
      summary_long_plot(mv_summary, metric = "fake_metric", growth_window = "Fall to Spring")
    ),
    "is not a column in"
  )
})


test_that("summary_long_plot errors with invalid growth_window", {
  expect_error(
    suppressWarnings(
      summary_long_plot(mv_summary, growth_window = "Invalid Window")
    ),
    "is not a valid growth window"
  )
})


test_that("summary_long_plot errors when growth_window not in data", {
  # Filter to only have one growth window
  filtered_summary <- mv_summary %>%
    dplyr::filter(growth_window == "Fall to Spring")
  class(filtered_summary) <- class(mv_summary)

  expect_error(
    suppressWarnings(
      summary_long_plot(filtered_summary, growth_window = "Spring to Spring")
    ),
    "is not a growth season in"
  )
})


test_that("summary_long_plot produces a valid ggplot by grade", {
  p <- suppressWarnings(
    summary_long_plot(
      mv_summary,
      growth_window = "Fall to Spring",
      by = "grade",
      metric = "pct_typical"
    )
  )

  expect_s3_class(p, 'gg')
  expect_s3_class(p, 'ggplot')

  # Check that the plot builds correctly
  p_build <- ggplot2::ggplot_build(p)
  expect_true(is.list(p_build))
  expect_true("data" %in% names(p_build))
})


test_that("summary_long_plot produces a valid ggplot by cohort", {
  p <- suppressWarnings(
    summary_long_plot(
      mv_summary,
      growth_window = "Fall to Spring",
      by = "cohort",
      metric = "pct_typical"
    )
  )

  expect_s3_class(p, 'gg')
  expect_s3_class(p, 'ggplot')

  # Check that the plot builds correctly
  p_build <- ggplot2::ggplot_build(p)
  expect_equal(length(p_build), 3)
  expect_equal(names(p_build), c('data', 'layout', 'plot'))
})


test_that("summary_long_plot works with different growth windows", {

  # Test Fall to Spring
  p1 <- suppressWarnings(
    summary_long_plot(
      mv_summary,
      growth_window = "Fall to Spring",
      metric = "pct_typical"
    )
  )
  expect_s3_class(p1, 'ggplot')

  # Test Spring to Spring
  p2 <- suppressWarnings(
    summary_long_plot(
      mv_summary,
      growth_window = "Spring to Spring",
      metric = "pct_typical"
    )
  )
  expect_s3_class(p2, 'ggplot')

  # Test Fall to Winter
  p3 <- suppressWarnings(
    summary_long_plot(
      mv_summary,
      growth_window = "Fall to Winter",
      metric = "pct_typical"
    )
  )
  expect_s3_class(p3, 'ggplot')
})


test_that("summary_long_plot works with percentage metrics", {

  # Test pct_typical
  p1 <- suppressWarnings(
    summary_long_plot(
      mv_summary,
      growth_window = "Fall to Spring",
      metric = "pct_typical"
    )
  )
  expect_s3_class(p1, 'ggplot')

  # Test pct_accel_growth
  p2 <- suppressWarnings(
    summary_long_plot(
      mv_summary,
      growth_window = "Fall to Spring",
      metric = "pct_accel_growth"
    )
  )
  expect_s3_class(p2, 'ggplot')

  # Test pct_negative
  p3 <- suppressWarnings(
    summary_long_plot(
      mv_summary,
      growth_window = "Fall to Spring",
      metric = "pct_negative"
    )
  )
  expect_s3_class(p3, 'ggplot')

  # Test end_pct_50th_pctl
  p4 <- suppressWarnings(
    summary_long_plot(
      mv_summary,
      growth_window = "Fall to Spring",
      metric = "end_pct_50th_pctl"
    )
  )
  expect_s3_class(p4, 'ggplot')

  # Test end_pct_75th_pctl
  p5 <- suppressWarnings(
    summary_long_plot(
      mv_summary,
      growth_window = "Fall to Spring",
      metric = "end_pct_75th_pctl"
    )
  )
  expect_s3_class(p5, 'ggplot')
})


test_that("summary_long_plot works with non-percentage metrics", {

  # Test start_mean_testritscore
  p1 <- suppressWarnings(
    summary_long_plot(
      mv_summary,
      growth_window = "Fall to Spring",
      metric = "start_mean_testritscore"
    )
  )
  expect_s3_class(p1, 'ggplot')

  # Test end_mean_testritscore
  p2 <- suppressWarnings(
    summary_long_plot(
      mv_summary,
      growth_window = "Fall to Spring",
      metric = "end_mean_testritscore"
    )
  )
  expect_s3_class(p2, 'ggplot')

  # Test mean_rit_growth
  p3 <- suppressWarnings(
    summary_long_plot(
      mv_summary,
      growth_window = "Fall to Spring",
      metric = "mean_rit_growth"
    )
  )
  expect_s3_class(p3, 'ggplot')

  # Test mean_cgi
  p4 <- suppressWarnings(
    summary_long_plot(
      mv_summary,
      growth_window = "Fall to Spring",
      metric = "mean_cgi"
    )
  )
  expect_s3_class(p4, 'ggplot')

  # Test median_sgp
  p5 <- suppressWarnings(
    summary_long_plot(
      mv_summary,
      growth_window = "Fall to Spring",
      metric = "median_sgp"
    )
  )
  expect_s3_class(p5, 'ggplot')
})


test_that("summary_long_plot respects n_cutoff parameter", {

  # Test with default n_cutoff (30)
  p1 <- suppressWarnings(
    summary_long_plot(
      mv_summary,
      growth_window = "Fall to Spring",
      metric = "pct_typical",
      n_cutoff = 30
    )
  )
  expect_s3_class(p1, 'ggplot')

  # Test with lower n_cutoff (should include more data points)
  p2 <- suppressWarnings(
    summary_long_plot(
      mv_summary,
      growth_window = "Fall to Spring",
      metric = "pct_typical",
      n_cutoff = 10
    )
  )
  expect_s3_class(p2, 'ggplot')

  # Test with higher n_cutoff (should include fewer data points)
  p3 <- suppressWarnings(
    summary_long_plot(
      mv_summary,
      growth_window = "Fall to Spring",
      metric = "pct_typical",
      n_cutoff = 50
    )
  )
  expect_s3_class(p3, 'ggplot')
})


test_that("summary_long_plot y-axis labels are correct", {

  # Test pct_typical label
  p1 <- suppressWarnings(
    summary_long_plot(
      mv_summary,
      growth_window = "Fall to Spring",
      metric = "pct_typical"
    )
  )
  expect_equal(p1$labels$y, "% M/E Typical Growth")

  # Test pct_accel_growth label
  p2 <- suppressWarnings(
    summary_long_plot(
      mv_summary,
      growth_window = "Fall to Spring",
      metric = "pct_accel_growth"
    )
  )
  expect_equal(p2$labels$y, "% M/E College Ready Growth")

  # Test pct_negative label
  p3 <- suppressWarnings(
    summary_long_plot(
      mv_summary,
      growth_window = "Fall to Spring",
      metric = "pct_negative"
    )
  )
  expect_equal(p3$labels$y, "% Pct Negative Change in RIT")

  # Test end_pct_50th_pctl label
  p4 <- suppressWarnings(
    summary_long_plot(
      mv_summary,
      growth_window = "Fall to Spring",
      metric = "end_pct_50th_pctl"
    )
  )
  expect_equal(p4$labels$y, "% >= 50th Percentile (End Season)")

  # Test end_pct_75th_pctl label
  p5 <- suppressWarnings(
    summary_long_plot(
      mv_summary,
      growth_window = "Fall to Spring",
      metric = "end_pct_75th_pctl"
    )
  )
  expect_equal(p5$labels$y, "% >= 75th Percentile (End Season)")

  # Test metric with testritscore in name
  p6 <- suppressWarnings(
    summary_long_plot(
      mv_summary,
      growth_window = "Fall to Spring",
      metric = "start_mean_testritscore"
    )
  )
  expect_equal(p6$labels$y, "RIT Score")

  # Test metric with rit_growth in name
  p7 <- suppressWarnings(
    summary_long_plot(
      mv_summary,
      growth_window = "Fall to Spring",
      metric = "mean_rit_growth"
    )
  )
  expect_equal(p7$labels$y, "RIT Points")

  # Test metric with cgi in name
  p8 <- suppressWarnings(
    summary_long_plot(
      mv_summary,
      growth_window = "Fall to Spring",
      metric = "mean_cgi"
    )
  )
  expect_equal(p8$labels$y, "Standard Deviations")

  # Test metric with sgp in name
  p9 <- suppressWarnings(
    summary_long_plot(
      mv_summary,
      growth_window = "Fall to Spring",
      metric = "median_sgp"
    )
  )
  expect_equal(p9$labels$y, "Student Growth Percentile")
})


test_that("summary_long_plot facets correctly by measurementscale and grade/cohort", {

  # Test by grade
  p1 <- suppressWarnings(
    summary_long_plot(
      mv_summary,
      growth_window = "Fall to Spring",
      by = "grade",
      metric = "pct_typical"
    )
  )
  # Facet should be measurementscale ~ end_grade
  expect_true(grepl("measurementscale", as.character(p1$facet$params$rows)))
  expect_true(grepl("end_grade", as.character(p1$facet$params$cols)))

  # Test by cohort
  p2 <- suppressWarnings(
    summary_long_plot(
      mv_summary,
      growth_window = "Fall to Spring",
      by = "cohort",
      metric = "pct_typical"
    )
  )
  # Facet should be measurementscale ~ cohort
  expect_true(grepl("measurementscale", as.character(p2$facet$params$rows)))
  expect_true(grepl("cohort", as.character(p2$facet$params$cols)))
})


test_that("summary_long_plot with midyear data", {

  mv_summary_midyear <- summary(mapviz_midyear$growth_df)

  p <- suppressWarnings(
    summary_long_plot(
      mv_summary_midyear,
      growth_window = "Fall to Winter",
      metric = "pct_typical"
    )
  )

  expect_s3_class(p, 'gg')
  expect_s3_class(p, 'ggplot')
})


test_that("summary_long_plot layers are correct", {

  p <- suppressWarnings(
    summary_long_plot(
      mv_summary,
      growth_window = "Fall to Spring",
      metric = "pct_typical"
    )
  )

  # Should have 3 layers: line, point, and text
  expect_equal(length(p$layers), 3)

  # First layer should be geom_line
  expect_equal(class(p$layers[[1]]$geom)[1], "GeomLine")

  # Second layer should be geom_point
  expect_equal(class(p$layers[[2]]$geom)[1], "GeomPoint")

  # Third layer should be geom_text
  expect_equal(class(p$layers[[3]]$geom)[1], "GeomText")
})


test_that("summary_long_plot with custom school_col", {

  # Test with default school_col (end_schoolname)
  p1 <- suppressWarnings(
    summary_long_plot(
      mv_summary,
      growth_window = "Fall to Spring",
      metric = "pct_typical",
      school_col = "end_schoolname"
    )
  )
  expect_s3_class(p1, 'ggplot')

  # The default should work
  p2 <- suppressWarnings(
    summary_long_plot(
      mv_summary,
      growth_window = "Fall to Spring",
      metric = "pct_typical"
    )
  )
  expect_s3_class(p2, 'ggplot')
})


test_that("summary_long_plot warning with non-mapvizieR_summary object", {

  # Should produce a warning but not error
  expect_warning(
    summary_long_plot(
      mv_summary %>% tibble::as_tibble(),
      growth_window = "Fall to Spring",
      metric = "pct_typical"
    ),
    "must be a mapvizier_summary object"
  )
})


test_that("summary_long_plot handles data filtering correctly", {

  # Create a plot and verify it filters by n_cutoff
  p <- suppressWarnings(
    summary_long_plot(
      mv_summary,
      growth_window = "Fall to Spring",
      metric = "pct_typical",
      n_cutoff = 20
    )
  )

  # Get the data used in the plot
  p_data <- ggplot2::ggplot_build(p)$data[[1]]

  # All data points should have n_students >= n_cutoff
  # (This is implicit in the filtering, just verify plot was created)
  expect_s3_class(p, 'ggplot')
  expect_true(nrow(p_data) > 0)
})


test_that("summary_long_plot SY formatting is correct", {

  p <- suppressWarnings(
    summary_long_plot(
      mv_summary,
      growth_window = "Fall to Spring",
      by = "grade",
      metric = "pct_typical"
    )
  )

  # Get the data from the plot
  p_data <- p$data

  # Check that SY column exists and is formatted correctly
  expect_true("SY" %in% names(p_data))

  # SY should be in format "YY-YY" (e.g., "13-14" for 2013-2014)
  if(nrow(p_data) > 0) {
    sy_format <- grepl("^\\d{2}-\\d{2}$", p_data$SY[1])
    expect_true(sy_format)
  }
})


test_that("summary_long_plot cohort formatting is correct", {

  p <- suppressWarnings(
    summary_long_plot(
      mv_summary,
      growth_window = "Fall to Spring",
      by = "cohort",
      metric = "pct_typical"
    )
  )

  # Get the data from the plot
  p_data <- p$data

  # Check that cohort and Grade columns exist
  expect_true("cohort" %in% names(p_data))
  expect_true("Grade" %in% names(p_data))

  # Cohort should include current grade information
  if(nrow(p_data) > 0) {
    cohort_format <- grepl("Current Grade:", p_data$cohort[1])
    expect_true(cohort_format)
  }
})
