context("becca_plot tests")

test_that("becca_plot errors when handed an improper mapviz object", {
  expect_error(
    becca_plot(cdf, studentids), 
    "The object you passed is not a conforming mapvizieR object"
  )  
})


test_that("becca_plot produces proper plot with a grade level of kids", {
        
  p <- becca_plot(mapviz, studentids_normal_use, 'Mathematics', detail_academic_year=2013)
  p_build <- ggplot2::ggplot_build(p)
  expect_true(is.ggplot(p))
  expect_equal(nrow(p_build$data[[1]]), 6)
  expect_equal(ncol(p_build$data[[2]]), 13)
  expect_equal(sum(p_build$data[[3]][, 2]), 133.871, tolerance = .001)
})



test_that("becca_plot returns expected data with a variety of groupings of kids", {
    
  valid_grades <- c(c(-0.8,4.2), seq(0:13))
  
  p <- becca_plot(mapviz, studentids_subset, 'Mathematics')
  p_build <- ggplot2::ggplot_build(p)
  expect_true(is.ggplot(p))
  expect_equal(nrow(p_build$data[[1]]), 8)

  p <- becca_plot(mapviz, studentids_subset, 'Mathematics', first_and_spring_only=FALSE)
  p_build <- ggplot2::ggplot_build(p)
  expect_true(is.ggplot(p))
  expect_equal(nrow(p_build$data[[1]]), 12)
  expect_equal(ncol(p_build$data[[1]]), 13)
  expect_equal(sum(p_build$data[[2]][, 3]), -398.8634, tolerance = .001)
  expect_equal(sum(p_build$data[[3]][, 2]), 358.9267, tolerance = .001)

  p <- becca_plot(mapviz, studentids_subset, 'Mathematics', first_and_spring_only=TRUE,
    entry_grade_seasons=c(7.2), small_n_cutoff=0.3)
  p_build <- ggplot2::ggplot_build(p)
  expect_true(is.ggplot(p))
  expect_equal(nrow(p_build$data[[1]]), 16)
  expect_equal(ncol(p_build$data[[1]]), 13)
  expect_equal(sum(p_build$data[[2]][, 3]), -648.1719, tolerance = .001)
  expect_equal(sum(p_build$data[[3]][, 2]),  456.7542, tolerance = .001)

  p <- becca_plot(mapviz, studentids_normal_use, 'Mathematics', detail_academic_year=2016)
  p_build <- ggplot2::ggplot_build(p)
  expect_true(is.ggplot(p))
  expect_equal(nrow(p_build$data[[1]]), 2)
  expect_equal(ncol(p_build$data[[1]]), 13)
  expect_equal(sum(p_build$data[[2]][, 3]), -110.7527, tolerance = .001)
  expect_equal(sum(p_build$data[[3]][, 2]), 46.77419, tolerance = .001)
  
  p <- becca_plot(mapviz, studentids_normal_use, 'Mathematics', first_and_spring_only=FALSE)
  p_build <- ggplot2::ggplot_build(p)
  expect_true(is.ggplot(p))
  expect_equal(nrow(p_build$data[[1]]), 6)
  expect_equal(ncol(p_build$data[[1]]), 13)
  expect_equal(sum(p_build$data[[2]][, 3]), -330.1075, tolerance = .001)
  expect_equal(sum(p_build$data[[3]][, 2]), 133.871, tolerance = .001)
  
  #alt colors
  p <- becca_plot(mapviz, studentids_subset, 'Mathematics', color_scheme = 'NYS')
  p_build <- ggplot2::ggplot_build(p)
  expect_true(is.ggplot(p))
  expect_equal(nrow(p_build$data[[1]]), 8)

  p <- becca_plot(mapviz, studentids_subset, 'Mathematics', 
    color_scheme = c('gray30', 'gray50', 'hotpink', 'dodgerblue'))
  p_build <- ggplot2::ggplot_build(p)
  expect_true(is.ggplot(p))
  expect_equal(nrow(p_build$data[[1]]), 8)
})


test_that("becca plot with bad color scheme should error in an informative way", {
  expect_error(
    becca_plot(mapviz, studentids_subset, 'Mathematics', color_scheme = 'pretty'),
    "color scheme should be either one of" 
  )
})


test_that("fuzz test becca_plot plot", {
  results <- fuzz_test_plot(
    'becca_plot', 
    n = 10,
    additional_args = list(
      'measurementscale' = 'Mathematics', 'detail_academic_year' = 2013
    ),
    mapvizieR_obj = mapviz
  )
  expect_true(all(unlist(results)))
  
  results <- fuzz_test_plot(
    plot_name = 'becca_plot', 
    n = 10, 
    additional_args = list(
     "first_and_spring_only" = FALSE, 'measurementscale' = 'Mathematics'
    ),
    mapvizieR_obj = mapviz
 )
 expect_true(all(unlist(results)))
 
})


test_that("becca_plot with ny state 'quartiles'", {
  
  p <- becca_plot(
    mapvizieR_obj = mapviz, 
    studentids = studentids_normal_use, 
    measurementscale = 'Mathematics',
    detail_academic_year = 2013,
    quartile_type = 'nys_math_3',
    color_scheme = 'NYS'
  )
  p_build <- ggplot2::ggplot_build(p)
  expect_is(p, 'ggplot')
  expect_equal(nrow(p_build$data[[1]]), 6)
  expect_equal(ncol(p_build$data[[2]]), 13)
  expect_equal(sum(p_build$data[[3]][, 2]), 88.70968, tolerance = .001)
  
})

