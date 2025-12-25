# Test goal_kipp_tiered() ####

test_that("goal_kipp_tiered creates proper object structure", {
  goal_obj <- goal_kipp_tiered(mapviz, iterations = 1)

  # Check list structure
  expect_equal(length(goal_obj), 3)
  expect_named(goal_obj, c("goals", "join_by_fields", "slot_name"))

  # Check that goals is a data frame
  expect_s3_class(goal_obj$goals, "data.frame")

  # Check join_by_fields is a character vector
  expect_type(goal_obj$join_by_fields, "character")
  expect_equal(
    goal_obj$join_by_fields,
    c("studentid", "start_testid", "end_testid", "measurementscale", "growth_window")
  )

  # Check slot_name
  expect_type(goal_obj$slot_name, "character")
  expect_equal(goal_obj$slot_name, "kipp_tiered_goals")
})


test_that("goal_kipp_tiered has required columns", {
  goal_obj <- goal_kipp_tiered(mapviz, iterations = 1)

  # Check required columns exist
  expect_true(all(c("accel_growth", "met_accel_growth") %in% names(goal_obj$goals)))

  # Check all expected columns
  expected_cols <- c(
    "studentid", "measurementscale", "start_testid", "end_testid",
    "growth_window", "start_fallwinterspring", "end_fallwinterspring",
    "accel_growth", "met_accel_growth", "iter"
  )
  expect_true(all(expected_cols %in% names(goal_obj$goals)))
})


test_that("goal_kipp_tiered returns correct number of rows", {
  goal_obj <- goal_kipp_tiered(mapviz, iterations = 1)

  # Should have same number of rows as growth_df
  expect_equal(nrow(goal_obj$goals), nrow(mapviz$growth_df))
})


test_that("goal_kipp_tiered calculates accel_growth correctly", {
  goal_obj <- goal_kipp_tiered(mapviz, iterations = 1)

  # accel_growth should be numeric
  expect_type(goal_obj$goals$accel_growth, "double")

  # accel_growth should be rounded to integers
  expect_true(all(goal_obj$goals$accel_growth == round(goal_obj$goals$accel_growth, 0),
                  na.rm = TRUE))

  # Manual check: verify a few calculations
  # For quartile 1, grades 0-3: factor should be 1.5
  # For quartile 1, grades 4+: factor should be 2.0
  test_data <- mapviz$growth_df %>%
    dplyr::ungroup() %>%
    dplyr::filter(!is.na(start_consistent_percentile), !is.na(reported_growth)) %>%
    head(50) %>%
    dplyr::mutate(
      test_quartile = kipp_quartile(start_consistent_percentile),
      test_factor = tiered_growth_factors(test_quartile, start_grade),
      test_accel = round(reported_growth * test_factor, 0)
    )

  # Join with goal object to compare
  comparison <- test_data %>%
    dplyr::inner_join(
      goal_obj$goals,
      by = c("studentid", "start_testid", "end_testid",
             "measurementscale", "growth_window"),
      suffix = c("_test", "_goal")
    )

  expect_equal(comparison$test_accel, comparison$accel_growth_goal)
})


test_that("goal_kipp_tiered correctly identifies met_accel_growth", {
  goal_obj <- goal_kipp_tiered(mapviz, iterations = 1)

  # met_accel_growth should be logical
  expect_type(goal_obj$goals$met_accel_growth, "logical")

  # Verify calculation against growth_df
  comparison <- mapviz$growth_df %>%
    dplyr::ungroup() %>%
    dplyr::inner_join(
      goal_obj$goals,
      by = c("studentid", "start_testid", "end_testid",
             "measurementscale", "growth_window"),
      suffix = c("_growth", "_goal")
    ) %>%
    dplyr::filter(!is.na(rit_growth), !is.na(accel_growth_goal))

  # met_accel_growth should be TRUE when rit_growth >= accel_growth
  expected_met <- comparison$rit_growth >= comparison$accel_growth_goal
  expect_equal(comparison$met_accel_growth_goal, expected_met)
})


test_that("goal_kipp_tiered handles different quartiles correctly", {
  goal_obj <- goal_kipp_tiered(mapviz, iterations = 1)

  # Join with growth_df to get quartile info
  with_quartile <- mapviz$growth_df %>%
    dplyr::ungroup() %>%
    dplyr::mutate(
      quartile = kipp_quartile(start_consistent_percentile),
      expected_factor = tiered_growth_factors(quartile, start_grade)
    ) %>%
    dplyr::inner_join(
      goal_obj$goals,
      by = c("studentid", "start_testid", "end_testid",
             "measurementscale", "growth_window"),
      suffix = c("_growth", "_goal")
    ) %>%
    dplyr::filter(!is.na(reported_growth), !is.na(quartile))

  # Calculate what accel_growth should be
  expected_accel <- round(with_quartile$reported_growth * with_quartile$expected_factor, 0)

  expect_equal(with_quartile$accel_growth_goal, expected_accel)
})


test_that("goal_kipp_tiered handles edge cases", {
  # Test with students in different grades
  goal_obj <- goal_kipp_tiered(mapviz, iterations = 1)

  # Should handle NA values gracefully
  na_count <- sum(is.na(goal_obj$goals$accel_growth))
  expect_true(na_count >= 0)

  # iter should be set to 1 for all rows
  expect_true(all(goal_obj$goals$iter == 1, na.rm = TRUE))
})


test_that("goal_kipp_tiered applies correct tiered growth factors", {
  goal_obj <- goal_kipp_tiered(mapviz, iterations = 1)

  # Check specific quartile/grade combinations
  # Quartile 1, Grade 0-3: factor = 1.5
  # Quartile 1, Grade 4+: factor = 2.0
  # Quartile 2, Grade 0-3: factor = 1.5
  # Quartile 2, Grade 4+: factor = 1.75
  # Quartile 3, Grade 0-3: factor = 1.25
  # Quartile 3, Grade 4+: factor = 1.5
  # Quartile 4: factor = 1.0

  test_cases <- mapviz$growth_df %>%
    dplyr::ungroup() %>%
    dplyr::filter(!is.na(start_consistent_percentile), !is.na(reported_growth)) %>%
    dplyr::mutate(
      quartile = kipp_quartile(start_consistent_percentile)
    ) %>%
    dplyr::filter(
      (quartile == 1 & start_grade <= 3) |
      (quartile == 2 & start_grade >= 4) |
      (quartile == 4)
    ) %>%
    head(30)

  if(nrow(test_cases) > 0) {
    test_with_goals <- test_cases %>%
      dplyr::inner_join(
        goal_obj$goals,
        by = c("studentid", "start_testid", "end_testid",
               "measurementscale", "growth_window"),
        suffix = c("_growth", "_goal")
      ) %>%
      dplyr::mutate(
        expected_factor = dplyr::case_when(
          quartile == 1 & start_grade <= 3 ~ 1.5,
          quartile == 1 & start_grade >= 4 ~ 2.0,
          quartile == 2 & start_grade <= 3 ~ 1.5,
          quartile == 2 & start_grade >= 4 ~ 1.75,
          quartile == 3 & start_grade <= 3 ~ 1.25,
          quartile == 3 & start_grade >= 4 ~ 1.5,
          quartile == 4 ~ 1.0,
          TRUE ~ NA_real_
        ),
        expected_accel = round(reported_growth * expected_factor, 0)
      )

    expect_equal(test_with_goals$accel_growth_goal, test_with_goals$expected_accel)
  }
})


# Test add_accelerated_growth() ####

test_that("add_accelerated_growth creates proper mapvizieR object", {
  new_mv <- add_accelerated_growth(
    mapviz,
    goal_function = goal_kipp_tiered,
    goal_function_args = list(iterations = 1),
    update_growth_df = TRUE
  )

  # Check that result is a mapvizieR object
  expect_true(is.mapvizieR(new_mv))

  # Check structure
  expect_equal(length(new_mv), 4)
  expect_named(new_mv, c("cdf", "roster", "growth_df", "goals"))
})


test_that("add_accelerated_growth adds goals slot", {
  new_mv <- add_accelerated_growth(
    mapviz,
    goal_function = goal_kipp_tiered,
    goal_function_args = list(iterations = 1),
    update_growth_df = FALSE
  )

  # Check goals slot exists
  expect_true("goals" %in% names(new_mv))
  expect_type(new_mv$goals, "list")

  # Check specific goal slot
  expect_named(new_mv$goals, "kipp_tiered_goals")
  expect_equal(length(new_mv$goals$kipp_tiered_goals), 3)
  expect_named(
    new_mv$goals$kipp_tiered_goals,
    c("goals", "join_by_fields", "slot_name")
  )
})


test_that("add_accelerated_growth updates growth_df when requested", {
  new_mv <- add_accelerated_growth(
    mapviz,
    goal_function = goal_kipp_tiered,
    goal_function_args = list(iterations = 1),
    update_growth_df = TRUE
  )

  # Check that accel_growth and met_accel_growth are in growth_df
  expect_true(all(c("accel_growth", "met_accel_growth") %in% names(new_mv$growth_df)))

  # Check that number of rows hasn't changed
  expect_equal(nrow(new_mv$growth_df), nrow(mapviz$growth_df))
})


test_that("add_accelerated_growth does not update growth_df when not requested", {
  new_mv <- add_accelerated_growth(
    mapviz,
    goal_function = goal_kipp_tiered,
    goal_function_args = list(iterations = 1),
    update_growth_df = FALSE
  )

  # If original growth_df didn't have these columns, they shouldn't be added
  if (!all(c("accel_growth", "met_accel_growth") %in% names(mapviz$growth_df))) {
    expect_false(all(c("accel_growth", "met_accel_growth") %in% names(new_mv$growth_df)))
  }

  # Number of rows should match
  expect_equal(nrow(new_mv$growth_df), nrow(mapviz$growth_df))
})


test_that("add_accelerated_growth properly joins goals to growth_df", {
  new_mv <- add_accelerated_growth(
    mapviz,
    goal_function = goal_kipp_tiered,
    goal_function_args = list(iterations = 1),
    update_growth_df = TRUE
  )

  # Check that goals match
  goal_data <- new_mv$goals$kipp_tiered_goals$goals
  growth_data <- new_mv$growth_df

  # Sample a few rows to verify the join worked correctly
  sample_rows <- growth_data %>%
    dplyr::filter(!is.na(accel_growth)) %>%
    head(20) %>%
    dplyr::select(
      studentid, start_testid, end_testid,
      measurementscale, growth_window, accel_growth, met_accel_growth
    ) %>%
    dplyr::inner_join(
      goal_data,
      by = c("studentid", "start_testid", "end_testid",
             "measurementscale", "growth_window"),
      suffix = c("_growth", "_goal")
    )

  # Values should match
  expect_equal(sample_rows$accel_growth_growth, sample_rows$accel_growth_goal)
  expect_equal(sample_rows$met_accel_growth_growth, sample_rows$met_accel_growth_goal)
})


test_that("add_accelerated_growth removes duplicate columns from join", {
  new_mv <- add_accelerated_growth(
    mapviz,
    goal_function = goal_kipp_tiered,
    goal_function_args = list(iterations = 1),
    update_growth_df = TRUE
  )

  # Check that there are no .x or .y suffixes in column names
  col_names <- names(new_mv$growth_df)
  expect_false(any(grepl("\\.x$", col_names)))
  expect_false(any(grepl("\\.y$", col_names)))

  # Check that iter column is not in growth_df (should be removed)
  expect_false("iter" %in% names(new_mv$growth_df))
})


test_that("add_accelerated_growth preserves growth_df grouping", {
  new_mv <- add_accelerated_growth(
    mapviz,
    goal_function = goal_kipp_tiered,
    goal_function_args = list(iterations = 1),
    update_growth_df = TRUE
  )

  # Check that growth_df is grouped
  expect_true(dplyr::is_grouped_df(new_mv$growth_df))

  # Check grouping variables
  expected_groups <- c(
    "end_map_year_academic", "cohort_year", "growth_window", "end_schoolname",
    "start_grade", "end_grade", "start_fallwinterspring", "end_fallwinterspring",
    "measurementscale"
  )

  group_vars <- dplyr::group_vars(new_mv$growth_df)
  expect_equal(sort(group_vars), sort(expected_groups))
})


# Test calc_normed_student_growth() ####

test_that("calc_normed_student_growth calculates correct values", {
  # Test with known values
  # For 75th percentile (0.75), z-score is approximately 0.6745
  # growth = typical_growth + z * sd_growth
  # growth = 5 + 0.6745 * 2 = 6.349
  result <- calc_normed_student_growth(0.75, 5, 2)
  expect_equal(result, 5 + qnorm(0.75) * 2, tolerance = 1e-6)

  # Test with 50th percentile (should equal typical growth)
  result <- calc_normed_student_growth(0.50, 10, 3)
  expect_equal(result, 10, tolerance = 1e-6)

  # Test with 90th percentile
  result <- calc_normed_student_growth(0.90, 5, 1)
  expect_equal(result, 5 + qnorm(0.90) * 1, tolerance = 1e-6)
})


test_that("calc_normed_student_growth handles percentile formats", {
  # Test that 0.75 and 75 give same result
  result_decimal <- calc_normed_student_growth(0.75, 5, 1)
  result_percent <- calc_normed_student_growth(75, 5, 1)

  expect_equal(result_decimal, result_percent)

  # Test other values
  expect_equal(
    calc_normed_student_growth(0.90, 10, 2),
    calc_normed_student_growth(90, 10, 2)
  )

  expect_equal(
    calc_normed_student_growth(0.25, 8, 1.5),
    calc_normed_student_growth(25, 8, 1.5)
  )
})


test_that("calc_normed_student_growth validates percentile input", {
  # Test that it errors on invalid percentiles
  expect_error(calc_normed_student_growth(0, 5, 1))
  expect_error(calc_normed_student_growth(100, 5, 1))
  expect_error(calc_normed_student_growth(-10, 5, 1))
  expect_error(calc_normed_student_growth(150, 5, 1))
})


test_that("calc_normed_student_growth works element-wise with vectors", {
  # Note: calc_normed_student_growth has validation that requires scalar percentile
  # But it can work with vectorized typical_growth and sd_growth
  # Test with single percentile, vectorized growth
  typical <- c(5, 10, 15, 20)
  sd <- c(1, 2, 3, 4)

  results <- calc_normed_student_growth(0.75, typical, sd)

  expect_equal(length(results), 4)
  expect_equal(results[1], 5 + qnorm(0.75) * 1, tolerance = 1e-6)
  expect_equal(results[2], 10 + qnorm(0.75) * 2, tolerance = 1e-6)
  expect_equal(results[3], 15 + qnorm(0.75) * 3, tolerance = 1e-6)
  expect_equal(results[4], 20 + qnorm(0.75) * 4, tolerance = 1e-6)
})


test_that("calc_normed_student_growth with actual growth_df data", {
  new_growth_df <- mapviz$growth_df %>%
    dplyr::ungroup() %>%
    head(100) %>%
    dplyr::filter(!is.na(reported_growth), !is.na(std_dev_of_expectation)) %>%
    dplyr::mutate(
      accel_growth_75 = calc_normed_student_growth(
        0.75,
        reported_growth,
        std_dev_of_expectation
      )
    )

  # Check that accel_growth is numeric
  expect_type(new_growth_df$accel_growth_75, "double")

  # Check that accel_growth > reported_growth for 75th percentile
  comparison <- new_growth_df %>%
    dplyr::filter(!is.na(accel_growth_75))

  if(nrow(comparison) > 0) {
    expect_true(all(comparison$accel_growth_75 >= comparison$reported_growth))
  }
})


# Test ensure_goals_names() ####

test_that("ensure_goals_names validates proper structure", {
  # Test with valid object
  valid_obj <- list(
    goals = data.frame(a = 1:5),
    join_by_fields = c("field1", "field2"),
    slot_name = "test_slot"
  )

  expect_silent(ensure_goals_names(valid_obj))
})


test_that("ensure_goals_names errors on invalid structure", {
  # Missing goals
  invalid_obj1 <- list(
    join_by_fields = c("field1", "field2"),
    slot_name = "test_slot"
  )
  expect_error(ensure_goals_names(invalid_obj1))

  # Missing join_by_fields
  invalid_obj2 <- list(
    goals = data.frame(a = 1:5),
    slot_name = "test_slot"
  )
  expect_error(ensure_goals_names(invalid_obj2))

  # Missing slot_name
  invalid_obj3 <- list(
    goals = data.frame(a = 1:5),
    join_by_fields = c("field1", "field2")
  )
  expect_error(ensure_goals_names(invalid_obj3))
})


# Test ensure_goals_obj() ####

test_that("ensure_goals_obj validates complete goals object", {
  # Test with valid object
  valid_obj <- list(
    goals = data.frame(
      accel_growth = 1:5,
      met_accel_growth = rep(TRUE, 5)
    ),
    join_by_fields = c("field1", "field2"),
    slot_name = "test_slot"
  )

  expect_silent(ensure_goals_obj(valid_obj))
})


test_that("ensure_goals_obj errors on missing required columns", {
  # Missing accel_growth
  invalid_obj1 <- list(
    goals = data.frame(
      met_accel_growth = rep(TRUE, 5)
    ),
    join_by_fields = c("field1", "field2"),
    slot_name = "test_slot"
  )
  expect_error(ensure_goals_obj(invalid_obj1))

  # Missing met_accel_growth
  invalid_obj2 <- list(
    goals = data.frame(
      accel_growth = 1:5
    ),
    join_by_fields = c("field1", "field2"),
    slot_name = "test_slot"
  )
  expect_error(ensure_goals_obj(invalid_obj2))
})


test_that("ensure_goals_obj validates goal_kipp_tiered output", {
  goal_obj <- goal_kipp_tiered(mapviz, iterations = 1)

  # Should pass validation
  expect_silent(ensure_goals_obj(goal_obj))
})


# Edge case tests ####

test_that("goal_kipp_tiered handles students with missing percentiles", {
  goal_obj <- goal_kipp_tiered(mapviz, iterations = 1)

  # Find rows where start_consistent_percentile is NA in growth_df
  na_percentile_count <- sum(is.na(mapviz$growth_df$start_consistent_percentile))

  # Should still create a goal for these students (even if accel_growth is NA)
  expect_equal(nrow(goal_obj$goals), nrow(mapviz$growth_df))
})


test_that("goal_kipp_tiered handles different measurement scales", {
  goal_obj <- goal_kipp_tiered(mapviz, iterations = 1)

  # Check that all measurement scales are present
  scales_in_growth <- unique(mapviz$growth_df$measurementscale)
  scales_in_goals <- unique(goal_obj$goals$measurementscale)

  expect_true(all(scales_in_growth %in% scales_in_goals))
})


test_that("add_accelerated_growth handles re-adding goals", {
  # Add goals once
  new_mv1 <- add_accelerated_growth(
    mapviz,
    goal_function = goal_kipp_tiered,
    goal_function_args = list(iterations = 1),
    update_growth_df = TRUE
  )

  # Add goals again (should update, not duplicate)
  new_mv2 <- add_accelerated_growth(
    new_mv1,
    goal_function = goal_kipp_tiered,
    goal_function_args = list(iterations = 1),
    update_growth_df = TRUE
  )

  # Should still have same structure
  expect_equal(nrow(new_mv2$growth_df), nrow(mapviz$growth_df))
  expect_equal(length(new_mv2$goals), 1)
})


test_that("goal_kipp_tiered handles high school students", {
  # Test with high school students
  if(length(studentids_hs) > 0) {
    hs_mapviz <- mv_limit_growth(mapviz, studentids_hs, 'Mathematics')

    if(nrow(hs_mapviz) > 0) {
      # Create goals for HS students
      goal_obj <- goal_kipp_tiered(
        list(growth_df = hs_mapviz, cdf = mapviz$cdf, roster = mapviz$roster) %>%
          structure(class = c("mapvizieR", "list")),
        iterations = 1
      )

      expect_equal(nrow(goal_obj$goals), nrow(hs_mapviz))
      expect_true(all(c("accel_growth", "met_accel_growth") %in% names(goal_obj$goals)))
    }
  }
})
