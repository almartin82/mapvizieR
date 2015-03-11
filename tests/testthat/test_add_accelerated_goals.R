context("adding accelerated growth goals to growth_df")
  
#make sure that constants used below exist
testing_constants()

test_that("goal_kipp_tiered creates proper object", {
  goal_obj <- goal_kipp_tiered(mapviz, iterations = 1)
  
  expect_equal(length(goal_obj), 3)
  expect_named(goal_obj, c("goals", "join_by_fields", "slot_name"))
  expect_true(all(c("accel_growth", "met_accel_growth") %in% names(goal_obj$goals)))
  expect_equal(nrow(goal_obj$goals), nrow(mapviz$growth_df))
})

test_that("add_accelerated_growth creates proper object", {
  new_mv <- add_accelerated_growth(
    mapviz, 
    goal_function = goal_kipp_tiered,
    goal_function_args = list(iterations=1),
    update_growth_df = TRUE
  )
  
  expect_true(is.mapvizieR(new_mv))
  expect_equal(length(new_mv), 4)
  expect_named(new_mv, c("cdf", "roster", "growth_df", "goals"))
  expect_true(all(c("accel_growth", "met_accel_growth") %in% names(new_mv$growth_df)))
  expect_named(new_mv$goals, "kipp_tiered_goals")
  expect_equal(nrow(new_mv$goals$kipp_tiered_goals$goals), nrow(new_mv$growth_df))
  expect_equal(nrow(new_mv$growth_df), nrow(mapviz$growth_df))
})



