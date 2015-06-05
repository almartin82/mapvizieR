context("estimate_rit tests")

test_that("estimate_rit does expected stuff ", {

  # test closest
  samp_val <- estimate_rit(mapviz,'F08000002','Mathematics','2013-10-20',method='closest')
  expect_equal(samp_val, 209)
  
  # test that forward parameter works
  samp_val <- estimate_rit(mapviz,'F08000002','Mathematics','2013-11-30',method='closest',forward=FALSE)
  expect_equal(samp_val, 209)
  
  # test lm
  samp_val <- estimate_rit(mapviz,'F08000002','Mathematics','2013-10-20',method='lm')
  expect_true(is.numeric(samp_val))
  
  # test interpolate
  samp_val <- estimate_rit(mapviz,'F08000002','Mathematics','2013-10-20',method='interpolate')
  expect_true(is.numeric(samp_val))
  
  # target_date is an test date
  samp_val <- estimate_rit(mapviz,'F08000002','Mathematics','2014-03-16',method='closest')
  expect_equal(samp_val,219)
  
  # check when student hasn't take test in given measurementscale
  samp_val <- estimate_rit(mapviz,'F08000002','General Science','2013-10-20',method='closest')
  expect_true(is.na(samp_val))
  
  # target_date before first test event
  samp_val <- estimate_rit(mapviz,'F08000002','Mathematics','2013-1-10',method='interpolate')
  expect_true(is.na(samp_val))
  
  # target_date after last test event
  samp_val <- estimate_rit(mapviz,'F08000002','Mathematics','2014-5-16',method='interpolate')
  expect_true(is.na(samp_val))
})