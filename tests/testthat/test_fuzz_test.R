context("very meta tests of the fuzz_test function")

#make sure that constants used below exist
testing_constants()

test_that("fuzz test a vanilla ggplot", {
  results <- fuzz_test_plot('silly_plot', n = 10)
  expect_true(all(unlist(results)))
})

test_that("fuzz test a vanilla ggplot", {    
  results <- fuzz_test_plot('error_ridden_plot', n = 3)
  expect_false(all(unlist(results)))
})

test_that("fuzz test treats a known error as TRUE result", {    
  
  roster <- mapviz[['roster']]
  mapviz[['roster']] <- roster[with(roster, grade == 11 & map_year_academic == 2013), ]
  
  results <- fuzz_test_plot(
    'goalbar', n = 10,
    additional_args = list('measurementscale' = 'Mathematics', 'start_fws' = 'Fall',
      'start_academic_year' = 2013, 'end_fws' = 'Spring', 'end_academic_year' = 2013),
    mapviz = mapviz
  )
  
  expect_true(all(unlist(results)))
})

