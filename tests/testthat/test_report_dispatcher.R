context("report dispatcher tests")

#make sure that constants used below exist
testing_constants()


test_that("basic test on silly plot.  report dispatcher should find roster structure on test data", {  
  
  cut_by <- list('schoolname', 'grade', 'studentgender')
  call_these <- list(FALSE, TRUE, TRUE)

  silly_test <- report_dispatcher(
    mapvizieR_obj = mapviz
   ,cut_list = cut_by
   ,call_list = call_these
   ,func_to_call = "silly_plot"
  )

  expect_equal(class(silly_test), "list")
  expect_equal(length(silly_test), 41)

})


test_that("report dispatcher on elephants using test data", {  
  cut_by <- list('schoolname')
  call_these <- list(TRUE)
  
  ele_test <- report_dispatcher(
    mapvizieR_obj = mapviz
   ,cut_list = cut_by
   ,call_list = call_these
   ,func_to_call = "galloping_elephants"
   ,arg_list = list('measurementscale'='Mathematics')
  )

  expect_equal(length(ele_test), 4)
  expect_true("ggplot" %in% class(ele_test[[1]]))
  expect_true(
    all(
      c("data","layers","scales","mapping","theme","coordinates","facet","plot_env","labels") %in%
       names(ele_test[[1]]) 
    )  
  )
  
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
    mapvizieR_obj = mapviz
   ,cut_list = cut_by
   ,call_list = call_these
   ,func_to_call = "galloping_elephants"
   ,arg_list = list('measurementscale'='Mathematics')
  )

  expect_equal(length(more_realistic), 17)
  expect_equal(sapply(more_realistic, class)[2,], c(rep("ggplot", 17)))
  
  realistic_build <- sapply(more_realistic, ggplot_build)
  expect_equal(length(realistic_build), 51)
  expect_equal(summary(realistic_build[1,])[,1], c(rep('3', 17)))
  expect_equal(rownames(summary(realistic_build[,1])), c('data', 'panel', 'plot'))
  
})  

