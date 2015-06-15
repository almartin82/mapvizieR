context("galloping elephants tests")

#make sure that constants used below exist
testing_constants()

test_that("galloping_elephants errors when handed an improper mapviz object", {
  expect_error(
    galloping_elephants(cdf, studentids), 
    "The object you passed is not a conforming mapvizieR object"
  )  
})


test_that("galloping_elephants produces proper plot with a grade level of kids", {
        
  p <- galloping_elephants(mapviz, studentids_normal_use, 'Mathematics')
  p_build <- ggplot_build(p)
  expect_true(is.ggplot(p))
  expect_equal(nrow(p_build$plot$data), 130)
  
})



test_that("galloping_elephants returns expected data with a nonsense grouping of kids", {
    
  valid_grades <- c(c(-0.8,4.2), seq(0:13))
    
  p <- galloping_elephants(mapviz, studentids_subset, 'Mathematics')
  p_build <- ggplot_build(p)
  expect_true(is.ggplot(p))
  expect_equal(nrow(p_build$plot$data), 1326)

  p <- galloping_elephants(mapviz, studentids_subset, 'Mathematics', first_and_spring_only=FALSE)
  p_build <- ggplot_build(p)
  expect_true(is.ggplot(p))
  expect_equal(nrow(p_build$plot$data), 2627)

  p <- galloping_elephants(mapviz, studentids_normal_use, 'Mathematics', detail_academic_year=2016)
  p_build <- ggplot_build(p)
  expect_true(is.ggplot(p))
  expect_equal(nrow(p_build$plot$data), 130)

  p <- galloping_elephants(mapviz, studentids_normal_use, 'Mathematics', first_and_spring_only=FALSE)
  p_build <- ggplot_build(p)
  expect_true(is.ggplot(p))
  expect_equal(nrow(p_build$plot$data), 316)
  
})


test_that("fuzz test elephants plot", {
  results <- fuzz_test_plot(
    'galloping_elephants', 
    n=25,
    additional_args=list('measurementscale'='Mathematics')
  )
  expect_true(all(unlist(results)))
  
  results <- fuzz_test_plot(
   plot_name = 'galloping_elephants', 
   n = 25, 
   additional_args=list("first_and_spring_only" = FALSE, 'measurementscale' = 'Mathematics')
 )
 expect_true(all(unlist(results)))
 
})
