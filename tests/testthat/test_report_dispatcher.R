context("report dispatcher tests")

test_that("basic test on silly plot.  report dispatcher should find roster structure on test data", {  
  
  mapviz <- mapvizieR(raw_cdf=ex_CombinedAssessmentResults, raw_roster=ex_CombinedStudentsBySchool)
  
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


