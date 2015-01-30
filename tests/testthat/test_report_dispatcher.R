context("report dispatcher tests")

#constants
mapviz <- mapvizieR(raw_cdf=ex_CombinedAssessmentResults, raw_roster=ex_CombinedStudentsBySchool)

test_that("basic test on silly plot.  report dispatcher should find roster structure on test data", {  
  
  cut_by <- list('schoolname', 'grade', 'studentgender')
  call_these <- list(FALSE, TRUE, TRUE)

  silly_test <- report_dispatcher(
    mapvizieR_obj=mapviz
   ,cut_list=cut_by
   ,call_list=call_these
   ,func_to_call="silly_plot"
  )

  expect_equal(class(silly_test), "list")
  expect_equal(length(silly_test), 41)

})


test_that("report dispatcher on elephants using test data", {  
  cut_by <- list('schoolname')
  call_these <- list(TRUE)
  
  ele_test <- report_dispatcher(
    mapvizieR_obj=mapviz
   ,cut_list=cut_by
   ,call_list=call_these
   ,func_to_call="galloping_elephants"
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


