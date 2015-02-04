context("very meta tests of the fuzz_test function")

test_that("fuzz test a vanilla ggplot", {
  results <- fuzz_test_plot('silly_plot', n=10)
  expect_true(all(unlist(results)))
})

test_that("fuzz test a vanilla ggplot", {    
  results <- fuzz_test_plot('error_ridden_plot', n=3)
  expect_false(all(unlist(results)))
})
