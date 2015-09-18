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
