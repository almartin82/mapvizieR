context("visual regression tests for plots")

# Skip visual regression tests - they are non-deterministic due to SVG grob names
# Run manually with: testthat::test_file("tests/testthat/test-visual-plots.R")
skip("vdiffr visual tests are non-deterministic - run manually when needed")
skip_on_cran()
skip_on_ci()

# Check for required packages
skip_if_not_installed("vdiffr")
skip_if_not_installed("ggplot2")

# Helper function to check if we have the test data
has_test_data <- function() {
  exists("mapviz") &&
  exists("studentids_normal_use") &&
  length(studentids_normal_use) > 0
}

test_that("becca_plot visual regression", {
  skip_if_not(has_test_data(), "Test data not available")

  # Create a stable becca plot
  p <- becca_plot(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Mathematics',
    detail_academic_year = 2013,
    first_and_spring_only = TRUE
  )

  # Check it's a ggplot
  expect_s3_class(p, 'ggplot')

  # Visual snapshot test
  vdiffr::expect_doppelganger(
    title = "becca_plot_mathematics_grade6_2013",
    fig = p
  )
})


test_that("becca_plot with NYS color scheme visual regression", {
  skip_if_not(has_test_data(), "Test data not available")

  # Create a becca plot with NYS color scheme
  p <- becca_plot(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Mathematics',
    detail_academic_year = 2013,
    color_scheme = 'NYS',
    quartile_type = 'nys_math_3'
  )

  expect_s3_class(p, 'ggplot')

  vdiffr::expect_doppelganger(
    title = "becca_plot_nys_color_scheme",
    fig = p
  )
})


test_that("haid_plot visual regression", {
  skip_if_not(has_test_data(), "Test data not available")

  # Create a stable haid plot
  p <- haid_plot(
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
    title = "haid_plot_reading_fall_to_spring_2013",
    fig = p
  )
})


test_that("haid_plot single season visual regression", {
  skip_if_not(has_test_data(), "Test data not available")

  # Create a haid plot with one season of data
  p <- haid_plot(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Mathematics',
    start_fws = 'Spring',
    start_academic_year = 2013,
    end_fws = 'Spring',
    end_academic_year = 2014
  )

  expect_s3_class(p, 'ggplot')

  vdiffr::expect_doppelganger(
    title = "haid_plot_mathematics_single_season",
    fig = p
  )
})


test_that("growth_histogram visual regression", {
  skip_if_not(has_test_data(), "Test data not available")

  # Create a stable growth histogram
  p <- growth_histogram(
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
    title = "growth_histogram_reading_fall_to_spring",
    fig = p
  )
})


test_that("growth_histogram with alternative student group", {
  skip_if_not(has_test_data(), "Test data not available")
  skip_if(!exists("cdf"), "CDF data not available")

  # Get a different group of students (grade 2)
  studentids_grade2 <- cdf %>%
    dplyr::filter(
      map_year_academic == 2013 &
      measurementscale == 'Mathematics' &
      fallwinterspring == 'Fall' &
      grade == 2
    ) %>%
    dplyr::ungroup() %>%
    as.data.frame() %>%
    dplyr::select(studentid) %>%
    unlist() %>%
    unname()

  skip_if(length(studentids_grade2) == 0, "No grade 2 students found")

  p <- growth_histogram(
    mapvizieR_obj = mapviz,
    studentids = studentids_grade2,
    measurementscale = 'Reading',
    start_fws = 'Fall',
    start_academic_year = 2013,
    end_fws = 'Spring',
    end_academic_year = 2013
  )

  expect_s3_class(p, 'ggplot')

  vdiffr::expect_doppelganger(
    title = "growth_histogram_grade2_reading",
    fig = p
  )
})


test_that("student_npr_history_plot visual regression", {
  skip_if_not(has_test_data(), "Test data not available")
  skip_if(!exists("mapviz"), "mapviz object not available")

  # Get a stable set of students for the history plot
  studentids_history <- mapviz$roster %>%
    dplyr::filter(
      grade == 8,
      schoolname == "Mt. Bachelor Middle School",
      termname == "Spring 2013-2014"
    ) %>%
    dplyr::select(studentid) %>%
    unique()

  skip_if(nrow(studentids_history) < 20, "Insufficient students for history plot")

  # Use first 20 students for stable snapshot
  p <- student_npr_history_plot(
    mapvizieR_obj = mapviz,
    studentids = studentids_history$studentid[1:20],
    measurementscale = 'Mathematics',
    title_text = ""
  )

  expect_s3_class(p, 'ggplot')

  vdiffr::expect_doppelganger(
    title = "student_npr_history_plot_mathematics_grade8",
    fig = p
  )
})


test_that("student_npr_history_plot reading subject", {
  skip_if_not(has_test_data(), "Test data not available")
  skip_if(!exists("mapviz"), "mapviz object not available")

  studentids_history <- mapviz$roster %>%
    dplyr::filter(
      grade == 8,
      schoolname == "Mt. Bachelor Middle School",
      termname == "Spring 2013-2014"
    ) %>%
    dplyr::select(studentid) %>%
    unique()

  skip_if(nrow(studentids_history) < 20, "Insufficient students for history plot")

  p <- student_npr_history_plot(
    mapvizieR_obj = mapviz,
    studentids = studentids_history$studentid[1:20],
    measurementscale = 'Reading',
    title_text = ""
  )

  expect_s3_class(p, 'ggplot')

  vdiffr::expect_doppelganger(
    title = "student_npr_history_plot_reading_grade8",
    fig = p
  )
})
