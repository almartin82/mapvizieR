context("report dispatcher tests")


test_that("basic test on silly plot.  report dispatcher should find roster structure on test data", {  
  
  cut_by <- list('schoolname', 'grade', 'studentgender')
  call_these <- list(FALSE, TRUE, TRUE)

  silly_test <- report_dispatcher(
    mapvizieR_obj = mapviz,
    cut_list = cut_by,
    call_list = call_these,
    func_to_call = "silly_plot",
    verbose = FALSE
  )

  expect_equal(class(silly_test), "list")
  expect_equal(length(silly_test), 41)

})


test_that("report dispatcher on elephants using test data", {  
  cut_by <- list('schoolname')
  call_these <- list(TRUE)
  
  ele_test <- report_dispatcher(
    mapvizieR_obj = mapviz,
    cut_list = cut_by,
    call_list = call_these,
    func_to_call = "galloping_elephants",
    arg_list = list('measurementscale' = 'Mathematics'),
    verbose = FALSE
  )

  expect_equal(length(ele_test), 4)
  expect_true("ggplot" %in% class(ele_test[[1]]))
  # ggplot2 S7 objects may not have names() - check components exist
  expect_true(!is.null(ele_test[[1]]$data))
  expect_true(!is.null(ele_test[[1]]$layers))
  expect_true(!is.null(ele_test[[1]]$mapping))
  
})  


test_that("only_valid_plots correctly handles a list of ggplot", {  

  ex <- list(
    silly_plot(mapviz, rand_stu(mapviz)),
    silly_plot(mapviz, rand_stu(mapviz)),
    try(silly_plot('farts'))
  )
  
  clean <- only_valid_plots(ex)
  
  expect_equal(length(clean), 2)
  expect_equal(sapply(clean, class)[2,], c(rep("ggplot", 2)))
  
  cut_by <- list('schoolname', 'grade')
  call_these <- list(TRUE, TRUE)

  more_realistic <- report_dispatcher(
    mapvizieR_obj = mapviz,
    cut_list = cut_by,
    call_list = call_these,
    func_to_call = "galloping_elephants",
    arg_list = list('measurementscale' = 'Mathematics'),
    verbose = FALSE
  )

  expect_equal(length(more_realistic), 17)
  expect_equal(sapply(more_realistic, class)[2,] %>% unname(), c(rep("ggplot", 17)))

  # ggplot_build with S7 returns list structure - verify builds succeed
  realistic_build <- lapply(more_realistic, ggplot_build)
  expect_equal(length(realistic_build), 17)
  expect_true(all(sapply(realistic_build, function(x) !is.null(x$data))))
  expect_true(all(sapply(realistic_build, function(x) !is.null(x$layout))))
  
})  


test_that("report dispatcher with two pager", {
  cut_list <- list('schoolname', 'grade')
  call_list <- list(TRUE, TRUE)
  
  samp_rd <- report_dispatcher(
    mapvizieR_obj = mapvizieR::mv_filter(
      mapviz, 
      roster_filter = quote(map_year_academic == 2013 & grade < 5)
    ),
    cut_list = cut_list,
    call_list = call_list,
    func_to_call = "two_pager",
    arg_list = list(
     'measurementscale' = 'Mathematics',
     'start_fws' = 'Fall',
     'start_academic_year' = 2013,
     'end_fws' = 'Spring',
     'end_academic_year' =  2013,
     'detail_academic_year' = 2099,
     'title_text' = quote(measurementscale)
    ), 
    verbose = FALSE
  )
  expect_equal(length(samp_rd), 6)
  expect_s3_class(samp_rd[[1]][[1]], "grob")
  expect_s3_class(samp_rd[[1]][[1]], "gtable")
  expect_s3_class(samp_rd[[1]][[1]], "gDesc")

})


test_that("report dispatcher throws an error if bad cut/call list provided", {  
  expect_error(
    report_dispatcher(
      mapvizieR_obj = mapviz,
      cut_list = list('schoolname', 'grade'),
      call_list = list(TRUE),
      func_to_call = "galloping_elephants",
      arg_list = list('measurementscale' = 'Mathematics'),
      verbose = FALSE
    ),
    "cut list and call list should be same length."
  )
})  


test_that("report dispatcher shows n per group if verbose", {
  diaz_ex <- utils::capture.output(report_dispatcher(
    mapvizieR_obj = mapviz,
    cut_list = list('schoolname', 'grade'),
    call_list = list(TRUE, TRUE),
    func_to_call = "galloping_elephants",
    arg_list = list('measurementscale' = 'Mathematics'),
    verbose = TRUE
  ))

  # Check that output contains expected school/grade combinations (positions may vary)
  expect_true(any(grepl("Mt. Bachelor Middle School.*grade: 6", diaz_ex)))
  expect_true(any(grepl("Three Sisters Elementary School.*grade: 5", diaz_ex)))
})  


