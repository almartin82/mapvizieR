context("Test CDF type detection and transformation functions")

data("ex_CombinedAssessmentResults_pre_2015")
data("ex_CombinedAssessmentResults")

# create client-server style cdf
ar_client_server <- ex_CombinedAssessmentResults_pre_2015 %>%
  dplyr::sample_n(30) %>%
  dplyr::mutate(TermName =  stringr::str_replace(TermName, "-\\d{4}", ""))

test_that("id_cdf_type detects client-server CDF", {
  expect_equal(id_cdf_type(ar_client_server), "Client-Server")
})

test_that("id_cdf_type detects pre-2015 WBM", {
  expect_equal(id_cdf_type(ex_CombinedAssessmentResults_pre_2015), 
               "WBM pre-2015")
})

test_that("id_cdf_type detects post-2015 WBM", {
  expect_equal(id_cdf_type(ex_CombinedAssessmentResults), 
               "WBM post-2015")
})


test_that("id_cdf_type detects unknown CDF type", {
  expect_equal(id_cdf_type(ex_CombinedAssessmentResults %>% select(1:5)), 
               "unknown")
})

test_that("migrate_cdf_to_2015_std migrates data from client-server to pre-2015 to post-2015", {
  
  x <- migrate_cdf_to_2015_std(ar_client_server)
  
  expect_true(all(grepl("^(fall|spring|winter) \\d{4}-\\d{4}$", tolower(x$TermName))))
  
  expect_identical(names(x), names(ex_CombinedAssessmentResults))
  
  expect_error(migrate_cdf_to_2015_std(ar_client_server[,1:5]))
  
})
