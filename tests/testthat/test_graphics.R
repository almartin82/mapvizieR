context("Tests that plot functions behave as expected")

test_that("galloping_elephants produces proper plot", {
  data(ex_CombinedAssessmentResults)
  data(ex_CombinedStudentsBySchool)
  mv<-mapvizieR(ex_CombinedAssessmentResults, ex_CombinedStudentsBySchool)
  
  sids <- sample(ex_CombinedStudentsBySchool$StudentID, 100) %>% 
    unique 
  
  valid_grades <- c(c(-0.8,4.2), seq(0:13))
  
  n_rows <- mv$cdf %>% 
    filter(studentid %in% sids,
           grade %in% valid_grades |
           map_year_academic==2014) %>%
    nrow
  
  p <- galloping_elephants(mv, sids)
  
  p_build <- ggplot_build(p)
  
  expect_true(is.ggplot(p))
  expect_equal(nrow(p_build$plot$data), n_rows)
  
})