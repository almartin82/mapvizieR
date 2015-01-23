context("checking that the CDF de-duping logic behaves as intended")

test_that("dedupe NWEA style returns one row per student/subject/term", {
  ex_roster <- prep_roster(ex_CombinedStudentsBySchool)
  ex_cdf <- prep_cdf_long(ex_CombinedAssessmentResults)
  
  dedupe_NWEA <- dedupe_cdf(ex_cdf, method="high RIT")
  
  hash <- paste(dedupe_NWEA$studentid, dedupe_NWEA$measurementscale, 
    dedupe_NWEA$map_year_academic, dedupe_NWEA$fallwinterspring, sep='_')
  
  counts <- as.data.frame(table(hash))
  
  #there should only ever be one count if dedupe is working
  assert_that(all(unlist(counts[,2])==TRUE))
})
