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



test_that("roster_to_cdf tests with matching roster col", {

  ex <- roster_to_cdf(
    target_df = mapviz$cdf,
    mapvizieR_obj = mapviz,
    roster_cols = 'schoolname'
  )
  #in this case we get back MORE rows on our cdf, because one student
  #has multiple school listings in the same term
  #see https://github.com/almartin82/mapvizieR/issues/195
  expect_equal(nrow(ex), 8553)
  expect_true('schoolname' %in% names(ex))
  expect_equal(table(ex$schoolname)[1] %>% unname(), 4217)
  expect_equal(table(ex$schoolname)[2] %>% unname(), 2265)
})


test_that("roster_to_growth_df tests", {

  ex <- roster_to_growth_df(
    target_df = mapviz$growth_df,
    mapvizieR_obj = mapviz,
    roster_cols = 'studentgender'
  )
  expect_equal(nrow(ex), nrow(mapviz$growth_df))
  expect_true('studentgender' %in% names(ex))
  expect_equal(table(ex$studentgender)[1] %>% unname(), 12906)
  expect_equal(table(ex$studentgender)[2] %>% unname(), 12848)
  
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
