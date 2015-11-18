context("goalbar tests")

test_that("goalbar errors when handed an improper mapviz object", {
  expect_error(
    goalbar(cdf, studentids), 
    "The object you passed is not a conforming mapvizieR object"
  )  
})


test_that("goalbar produces proper plot with a grade level of kids", {
        
  p <- goalbar(mapviz, studentids_normal_use, 'Mathematics', 'Fall', 2013,
         'Spring', 2013)
  p_build <- ggplot_build(p)
  expect_true(is.ggplot(p))
  expect_equal(nrow(p_build$data[[1]]), 4)
  expect_equal(sum(p_build$data[[1]][, 6]), 154, tolerance=.001)  
  expect_equal(ncol(p_build$data[[2]]), 6)
  expect_equal(sum(p_build$data[[2]][, 3]), 200.5, tolerance=.001)
  
  p <- goalbar(mapviz, studentids_normal_use, 'Mathematics', 'Fall', 2013,
         'Spring', 2013, complete_obsv=TRUE)
  p_build <- ggplot_build(p)
  expect_true(is.ggplot(p))
  expect_equal(nrow(p_build$data[[1]]), 4)
  expect_equal(sum(p_build$data[[1]][, 6]), 154, tolerance=.001)  
  expect_equal(ncol(p_build$data[[2]]), 6)
  expect_equal(sum(p_build$data[[2]][, 3]), 200.5, tolerance=.001)

})


test_that("goalbar works with ontrack params",{
  
  p <- goalbar(mapviz, studentids_normal_use, 'Mathematics', 'Fall', 2013,
         'Spring', 2013, ontrack_prorater = 0.5, ontrack_fws = 'Winter',
        ontrack_academic_year = 2014)
  expect_true(is.ggplot(p))
  
  p_build <- ggplot_build(p)
  expect_equal(sum(p_build$data[[2]][, 3]), 200.5, tolerance=.001)
  
})


test_that("goalbar works with ontrack params and simulated midyear data",{
  
  p <- goalbar(mapviz_midyear, studentids_normal_use, 'Mathematics', 'Fall', 2013,
         'Spring', 2013, ontrack_prorater = 0.5, ontrack_fws = 'Winter',
        ontrack_academic_year = 2013)
  expect_true(is.ggplot(p))
  
  p_build <- ggplot_build(p)
  expect_equal(sum(p_build$data[[2]][, 3]), 53.5, tolerance=.001)
  
})


test_that("goalbar should throw a warning if some students cant be categorized",{
    
  expect_warning(
    goalbar(mapviz, studentids_hs, 'Mathematics', 'Fall', 2013,
         'Spring', 2013),
    "the data frame used to make the plot was not able to categorize 51 rows."
  )
           
})


test_that("goalbar should throw a error if no students have normative data",{
    
  expect_error(
    goalbar(mapviz, studentids_gr11, 'Mathematics', 'Fall', 2013,
         'Spring', 2013),
    "Sorry, can't plot that: None of the students in your selection have typical growth norms"
  )
           
})


test_that("fuzz test goalbar plot", {
  results <- fuzz_test_plot(
    'goalbar', 
    n=10,
    additional_args=list('measurementscale' = 'Mathematics', 'start_fws' = 'Fall',
      'start_academic_year' = 2013, 'end_fws' = 'Spring', 'end_academic_year' = 2013)
  )
  expect_true(all(unlist(results)))
})


test_that("min subgroup filter test", {
  
  silly_ex <- min_subgroup_filter(roster, 'studentgender', 0.5)
  expect_equal(nrow(roster), nrow(silly_ex))
  
  ethnic_ex <- min_subgroup_filter(roster, 'studentethnicgroup', 0.1)
  expect_equal(
    ethnic_ex$studentethnicgroup %>% unique(), 
    c("Hispanic or Latino", "White", "Black or African American")
  )
  expect_equal(nrow(ethnic_ex), 2543)
})