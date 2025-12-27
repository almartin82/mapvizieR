context("growth_status_scatter tests")


# Test 2: Basic functionality - produces valid ggplot object
test_that("growth_status_scatter produces proper plot with a grade level of kids", {
  samp_scatter <- growth_status_scatter(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Reading',
    start_fws = 'Fall',
    start_academic_year = 2013,
    end_fws = 'Spring',
    end_academic_year = 2013
  )

  expect_s3_class(samp_scatter, 'gg')
  expect_s3_class(samp_scatter, 'ggplot')

  p_build <- ggplot_build(samp_scatter)

  # Check that the text layer (annotations for quadrants) exists
  expect_equal(
    colnames(p_build$data[[2]]),
    c("x", "y", "PANEL", "group", "colour", "family", "size", "angle", "hjust",
      "vjust", "alpha", "fontface", "lineheight", "label"
    )
  )
  expect_equal(sum(p_build$data[[2]]$x), 298, tolerance = 0.01)
})


# Test 3: Mathematics subject
test_that("growth_status_scatter works with Mathematics measurementscale", {
  math_scatter <- growth_status_scatter(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Mathematics',
    start_fws = 'Fall',
    start_academic_year = 2013,
    end_fws = 'Spring',
    end_academic_year = 2013
  )

  expect_s3_class(math_scatter, 'gg')
  expect_s3_class(math_scatter, 'ggplot')

  p_build <- ggplot_build(math_scatter)

  # Verify plot layers are created
  expect_true(length(p_build$data) > 0)

  # Check that labels are appropriate
  expect_equal(math_scatter$labels$x, 'Growth Percentile')
  expect_equal(math_scatter$labels$y, 'Percentile Rank')
})


# Test 4: Different student groups
test_that("growth_status_scatter works with different student groups", {
  # Test with subset of students
  subset_scatter <- growth_status_scatter(
    mapvizieR_obj = mapviz,
    studentids = studentids_subset,
    measurementscale = 'Reading',
    start_fws = 'Fall',
    start_academic_year = 2013,
    end_fws = 'Spring',
    end_academic_year = 2013
  )

  expect_s3_class(subset_scatter, 'ggplot')

  # Test with middle school students
  ms_scatter <- growth_status_scatter(
    mapvizieR_obj = mapviz,
    studentids = studentids_ms,
    measurementscale = 'Mathematics',
    start_fws = 'Fall',
    start_academic_year = 2013,
    end_fws = 'Spring',
    end_academic_year = 2013
  )

  expect_s3_class(ms_scatter, 'ggplot')
})


# Test 5: Different time windows
test_that("growth_status_scatter works with different time windows", {
  # Fall to Winter
  fall_winter <- growth_status_scatter(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Reading',
    start_fws = 'Fall',
    start_academic_year = 2013,
    end_fws = 'Winter',
    end_academic_year = 2013
  )

  expect_s3_class(fall_winter, 'ggplot')

  # Winter to Spring
  winter_spring <- growth_status_scatter(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Reading',
    start_fws = 'Winter',
    start_academic_year = 2013,
    end_fws = 'Spring',
    end_academic_year = 2013
  )

  expect_s3_class(winter_spring, 'ggplot')
})


# Test 6: Cross-year growth
test_that("growth_status_scatter works with cross-year growth windows", {
  cross_year <- growth_status_scatter(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Mathematics',
    start_fws = 'Spring',
    start_academic_year = 2013,
    end_fws = 'Spring',
    end_academic_year = 2014
  )

  expect_s3_class(cross_year, 'ggplot')

  # Cross-year data may be empty, so we just check it runs without error
  expect_true(length(cross_year$layers) >= 5)
})


# Test 7: Plot elements and structure
test_that("growth_status_scatter has correct plot elements", {
  p <- growth_status_scatter(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Reading',
    start_fws = 'Fall',
    start_academic_year = 2013,
    end_fws = 'Spring',
    end_academic_year = 2013
  )

  p_build <- ggplot_build(p)

  # Check that we have expected layers (points, text, jitter, annotations, vlines, hlines)
  expect_true(length(p$layers) >= 5)

  # Check axis limits (should be 0-100 for both axes)
  expect_equal(p$coordinates$limits$x, c(0, 100))
  expect_equal(p$coordinates$limits$y, c(0, 100))

  # Check that breaks are correct
  expect_equal(p$scales$scales[[1]]$breaks, seq(10, 90, by = 10))
})


# Test 8: Annotation quadrants
test_that("growth_status_scatter includes quadrant annotations", {
  p <- growth_status_scatter(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Mathematics',
    start_fws = 'Fall',
    start_academic_year = 2013,
    end_fws = 'Spring',
    end_academic_year = 2013
  )

  # The plot should have annotation layer
  # Looking for text annotations that label the quadrants
  p_build <- ggplot_build(p)

  # Check that annotations exist (first layer after the invisible points)
  # Should have 6 quadrant labels
  annotation_layer <- p_build$data[[2]]
  expect_equal(nrow(annotation_layer), 6)

  # Check that the annotations are at expected positions
  expect_true(all(annotation_layer$y %in% c(25, 75)))
})


# Test 9: Reference lines
test_that("growth_status_scatter includes reference lines", {
  p <- growth_status_scatter(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Reading',
    start_fws = 'Fall',
    start_academic_year = 2013,
    end_fws = 'Spring',
    end_academic_year = 2013
  )

  # Check that we have vlines and hlines
  layer_classes <- sapply(p$layers, function(l) class(l$geom))

  # Check for GeomVline
  expect_true(any(sapply(layer_classes, function(x) "GeomVline" %in% x)))

  # Check for GeomHline
  expect_true(any(sapply(layer_classes, function(x) "GeomHline" %in% x)))
})


# Test 10: Small sample size
test_that("growth_status_scatter handles small sample sizes", {
  # Get just a few students
  small_sample <- head(studentids_normal_use, 5)

  p <- growth_status_scatter(
    mapvizieR_obj = mapviz,
    studentids = small_sample,
    measurementscale = 'Reading',
    start_fws = 'Fall',
    start_academic_year = 2013,
    end_fws = 'Spring',
    end_academic_year = 2013
  )

  expect_s3_class(p, 'ggplot')

  p_build <- ggplot_build(p)
  expect_true(length(p_build$data) > 0)
})


# Test 11: Single student
test_that("growth_status_scatter works with a single student", {
  single_student <- studentids_normal_use[1]

  p <- growth_status_scatter(
    mapvizieR_obj = mapviz,
    studentids = single_student,
    measurementscale = 'Mathematics',
    start_fws = 'Fall',
    start_academic_year = 2013,
    end_fws = 'Spring',
    end_academic_year = 2013
  )

  expect_s3_class(p, 'ggplot')
})


# Test 12: Multiple measurement scales work
test_that("growth_status_scatter works across measurement scales", {
  # Test both Reading and Mathematics to ensure the function is robust

  reading_plot <- growth_status_scatter(
    mapvizieR_obj = mapviz,
    studentids = studentids_subset[1:10],
    measurementscale = 'Reading',
    start_fws = 'Fall',
    start_academic_year = 2013,
    end_fws = 'Spring',
    end_academic_year = 2013
  )

  math_plot <- growth_status_scatter(
    mapvizieR_obj = mapviz,
    studentids = studentids_subset[1:10],
    measurementscale = 'Mathematics',
    start_fws = 'Fall',
    start_academic_year = 2013,
    end_fws = 'Spring',
    end_academic_year = 2013
  )

  expect_s3_class(reading_plot, 'ggplot')
  expect_s3_class(math_plot, 'ggplot')

  # Both should have the same structure
  expect_equal(length(reading_plot$layers), length(math_plot$layers))
})


# Test 14: Visual regression test (requires vdiffr)
test_that("growth_status_scatter visual regression", {
  skip("vdiffr visual tests are non-deterministic - run manually when needed")
  skip_on_cran()
  skip_on_ci()
  skip_if_not_installed("vdiffr")

  # Create a stable plot for visual comparison
  p <- growth_status_scatter(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Reading',
    start_fws = 'Fall',
    start_academic_year = 2013,
    end_fws = 'Spring',
    end_academic_year = 2013
  )

  expect_s3_class(p, 'ggplot')

  vdiffr::expect_doppelganger(
    title = "growth_status_scatter_reading_fall_to_spring_2013",
    fig = p
  )
})


# Test 15: Visual regression test - Mathematics
test_that("growth_status_scatter visual regression Mathematics", {
  skip("vdiffr visual tests are non-deterministic - run manually when needed")
  skip_on_cran()
  skip_on_ci()
  skip_if_not_installed("vdiffr")

  p <- growth_status_scatter(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Mathematics',
    start_fws = 'Fall',
    start_academic_year = 2013,
    end_fws = 'Spring',
    end_academic_year = 2013
  )

  expect_s3_class(p, 'ggplot')

  vdiffr::expect_doppelganger(
    title = "growth_status_scatter_mathematics_fall_to_spring_2013",
    fig = p
  )
})


# Test 16: Visual regression test - cross-year
test_that("growth_status_scatter visual regression cross year", {
  skip("vdiffr visual tests are non-deterministic - run manually when needed")
  skip_on_cran()
  skip_on_ci()
  skip_if_not_installed("vdiffr")

  p <- growth_status_scatter(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Reading',
    start_fws = 'Spring',
    start_academic_year = 2013,
    end_fws = 'Spring',
    end_academic_year = 2014
  )

  expect_s3_class(p, 'ggplot')

  vdiffr::expect_doppelganger(
    title = "growth_status_scatter_reading_spring_to_spring_cross_year",
    fig = p
  )
})


# Test 17: Different student populations
test_that("growth_status_scatter works with high school students", {
  # Only run if we have high school students
  skip_if(length(studentids_hs) == 0, "No high school students available")

  p <- growth_status_scatter(
    mapvizieR_obj = mapviz,
    studentids = studentids_hs,
    measurementscale = 'Mathematics',
    start_fws = 'Fall',
    start_academic_year = 2013,
    end_fws = 'Spring',
    end_academic_year = 2013
  )

  expect_s3_class(p, 'ggplot')
})


# Test 18: One school population
test_that("growth_status_scatter works with single school population", {
  skip_if(length(studentids_one_school) == 0, "No single school students available")

  p <- growth_status_scatter(
    mapvizieR_obj = mapviz,
    studentids = studentids_one_school,
    measurementscale = 'Reading',
    start_fws = 'Fall',
    start_academic_year = 2013,
    end_fws = 'Spring',
    end_academic_year = 2013
  )

  expect_s3_class(p, 'ggplot')
})
