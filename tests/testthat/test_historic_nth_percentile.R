context("historic nth percentile plot")

test_that("historic nth percentile plot generates ggplot object", {
  
  ex <- historic_nth_percentile_plot(
    mapviz, 
    mapviz$roster %>% 
      dplyr::filter(schoolname == 'Three Sisters Elementary School') %>% 
      dplyr::select(studentid) %>% unlist() %>% unname(),
    'Mathematics'
  )
  
  expect_is(ex, 'ggplot')
  
})