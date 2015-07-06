context("roster_to_df tests")

#make sure that constants used below exist
testing_constants()

test_that("roster_to_cdf tests", {

  ex <- roster_to_cdf(
    target_df = mapviz$cdf,
    mapvizieR_obj = mapviz,
    roster_cols = 'studentgender'
  )
  expect_equal(nrow(ex), nrow(mapviz$cdf))
  expect_true('studentgender' %in% names(ex))
  expect_equal(table(ex$studentgender)[1] %>% unname(), 4283)
  expect_equal(table(ex$studentgender)[2] %>% unname(), 4268)
  
})


test_that("roster_to_growth_df tests", {

  ex <- roster_to_growth_df(
    target_df = mapviz$growth_df,
    mapvizieR_obj = mapviz,
    roster_cols = 'studentgender'
  )
  expect_equal(nrow(ex), nrow(mapviz$growth_df))
  expect_true('studentgender' %in% names(ex))
  expect_equal(table(ex$studentgender)[1] %>% unname(), 8546)
  expect_equal(table(ex$studentgender)[2] %>% unname(), 8464)
  
})


test_that("bad data tests", {

  expect_error(
    roster_to_cdf(mapviz$growth_df, mapviz, 'studentgender'),
    "you provided a growth df, but this function is designed for the cdf"
  )
  
  expect_error(
    roster_to_growth_df(mapviz$cdf, mapviz, 'studentgender'),
    "you provided a regular cdf, but this function is designed for the growth_df."
  )
})