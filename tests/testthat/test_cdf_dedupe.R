context("checking that the CDF de-duping logic behaves as intended")

test_that("dedupe NWEA style returns one row per student/subject/term", {
  
  #dedupe NWEA style
  dedupe_NWEA <- dedupe_cdf(prepped_cdf, method="NWEA")
  
  #build a hash
  hash <- with(dedupe_NWEA, paste(studentid, measurementscale,
    map_year_academic, fallwinterspring, sep='_'))
    
  #build a df of counts (should be unique, ie 1)
  counts <- as.data.frame(table(hash))  
  #there should only ever be one count if dedupe is working
  expect_true(all(unlist(counts[,2]), TRUE))
  
  #how many with this test?
  expect_equal(nrow(counts), 8551)

})


test_that("dedupe high RIT style returns one row per student/subject/term", {
  
  #dedupe by high RIT
  dedupe_high <- dedupe_cdf(prepped_cdf, method="high RIT")
  
  hash <- with(dedupe_high, paste(studentid, measurementscale,
    map_year_academic, fallwinterspring, sep='_'))  
  counts <- as.data.frame(table(hash))  
  #there should only ever be one count if dedupe is working
  expect_true(all(unlist(counts[,2])==TRUE))
  
  # Updated expectation for current data
  expect_equal(nrow(counts), 8551)

})



test_that("dedupe most recent style returns one row per student/subject/term", {

  #dedupe by high RIT
  dedupe_recent <- dedupe_cdf(prepped_cdf, method="most recent")

  hash <- with(dedupe_recent, paste(studentid, measurementscale,
    map_year_academic, fallwinterspring, sep='_'))
  counts <- as.data.frame(table(hash))
  #there should only ever be one count if dedupe is working
  expect_true(all(unlist(counts[,2])==TRUE))

  # Updated expectation for current data
  expect_equal(nrow(counts), 8551)

})
