context("growth_status_scatter tests")

test_that("impute_rit only accepts valid inputs", {

  expect_error(
    impute_rit(
      mapvizieR_obj = mapviz,
      studentids = studentids_normal_use,
      measurementscale = 'Mathematics',
      impute_method = 'intentionally broken'
    ),
    'is not a valid imputation method'
  )

})


test_that("imputation_scaffold", {
  
  cs <- imputation_scaffold(processed_cdf)
  
  expect_equal(nrow(cs), 8602)
  expect_is(cs, 'data.frame')
  expect_equal(sum(cs$grade_level_season), 56325.5)
  
})


test_that("impute_rit_simple_average repairs cdf with intentionally missing rows", {
  
  missing_cdf <- processed_cdf
  missing_cdf <- missing_cdf %>%
    dplyr::filter(!testid %in% c(122220145, 122220176))
  
  sa <- impute_rit_simple_average(missing_cdf)
  
  expect_equal(
    sa %>% dplyr::filter(
        studentid == 'SF06000348' & is.na(testid) & measurementscale == 'Mathematics') %>%
      dplyr::select(testritscore) %>% unlist() %>% unname(),
    c(176, 184)
  )
})


test_that("impute_rit_simple_average warns if interpolate isn't true", {
  
  expect_error(
    impute_rit_simple_average(processed_cdf, interpolate_only = FALSE)
  )
})


test_that("imput_rit wrapper with simple average densifies cdf", {
  
  missing_cdf <- processed_cdf
  missing_cdf <- missing_cdf %>%
    dplyr::filter(!testid %in% c(122220145, 122220176))
  
  mapviz$cdf <- missing_cdf
  impute_studentids <- roster %>% dplyr::filter(map_year_academic == 2013 & grade == 1) %>% 
    dplyr::select(studentid) %>% unname() %>% unlist()
  
  i <- impute_rit(
    mapvizieR_obj = mapviz,
    studentids = impute_studentids,
    measurementscale = 'Mathematics'
  )
  
  expect_equal(
    i[i$studentid == 'SF06000348' & is.na(i$testid), ]$testritscore, c(176, 184)
  )
  expect_equal(nrow(i), 64)
  
  expect_equal(table(i$row_type)['imputed'] %>% unname(), 2)
  expect_equal(table(i$row_type)['observed'] %>% unname(), 62)  
})