context("very meta tests of the fuzz_test function")

test_that("fuzz test a vanilla ggplot", {
  results <- fuzz_test_plot('silly_plot', n=25)
  expect_true(all(unlist(results)))
})

