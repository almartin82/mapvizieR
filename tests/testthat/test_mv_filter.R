context("mapvizier filter tests")

#make sure that constants used below exist
testing_constants()


test_that("mapvizier filters cdf year", {
  filter_ex <- mv_filter(
    mapvizieR_obj = mapviz, 
    cdf_filter = quote(map_year_academic == 2013)
  )
  
  expect_equal(nrow(filter_ex[['cdf']]), 6558)

  filter_ex <- mv_filter(
    mapvizieR_obj = mapviz, 
    cdf_filter = quote(map_year_academic == 2012)
  )
  
  expect_equal(nrow(filter_ex[['cdf']]), 1993)
})
  

test_that("mapvizier filters cdf grade", {
  filter_ex <- mv_filter(
    mapvizieR_obj = mapviz, 
    cdf_filter = quote(grade == 6)
  )
  
  expect_equal(nrow(filter_ex[['cdf']]), 1185)
})
  

test_that("mapvizier filters cdf year and grade", {
  filter_ex <- mv_filter(
    mapvizieR_obj = mapviz, 
    cdf_filter = quote(map_year_academic == 2013 & grade == 6)
  )
  
  expect_equal(nrow(filter_ex[['cdf']]), 837)
})



test_that("mapvizier filters roster one category", {
  filter_ex <- mv_filter(
    mapvizieR_obj = mapviz, 
    roster_filter = quote(schoolname == "Three Sisters Elementary School")
  )
  
  expect_equal(nrow(filter_ex[['cdf']]), 1883)
})


test_that("mapvizier filters roster two categories", {
  #students who were ever in the 3rd grade (kind of weird - remember that roster has *all* enrollments)
  filter_ex <- mv_filter(
    mapvizieR_obj = mapviz, 
    roster_filter = quote(schoolname == "Three Sisters Elementary School" &  grade == 3)
  )
  
  expect_equal(nrow(filter_ex[['cdf']]), 656)
})


test_that("mapvizier filters cdf AND roster", {
  #students who were ever in the 3rd grade (kind of weird - remember that roster has *all* enrollments)
  filter_ex <- mv_filter(
    mapvizieR_obj = mapviz, 
    cdf_filter = quote(map_year_academic == 2013),
    roster_filter = quote(schoolname == "Three Sisters Elementary School")
  )
  
  expect_equal(nrow(filter_ex[['cdf']]), 1401)
})