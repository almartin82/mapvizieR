context("haid_plot tests")

#make sure that constants used below exist
testing_constants()

test_that("haid_plot errors when handed an improper mapviz object", {
  expect_error(
    haid_plot(processed_cdf, studentids), 
    "The object you passed is not a conforming mapvizieR object"
  )  
})


test_that("haid_plot produces proper plot with a grade level of kids", {
  samp_haid <- haid_plot(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Reading',
    start_fws = 'Fall',
    start_academic_year = 2013,
    end_fws = 'Spring',
    end_academic_year = 2013
  )
  
  expect_is(samp_haid, 'gg')
  expect_is(samp_haid, 'ggplot')
  
  expect_equal(length(samp_haid), 9)
  expect_equal(names(samp_haid), 
    c("data", "layers", "scales", "mapping", "theme", "coordinates", 
      "facet", "plot_env", "labels")             
  )
  
  p_build <- ggplot_build(samp_haid)
  
  expect_equal(length(p_build), 3)
  expect_equal(
    dimnames(p_build[[1]][[2]])[[2]],
    c("y", "x", "PANEL", "group")
  )
  expect_equal(sum(p_build[[1]][[5]]$xend), 19884, tolerance=0.01)
  
})


test_that("haid_plot with one season of data", {
  one_season <- haid_plot(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Mathematics',
    start_fws = 'Spring',
    start_academic_year = 2013,
    end_fws = 'Spring',
    end_academic_year = 2014
  )
  
  expect_is(one_season, 'gg')
  expect_is(one_season, 'ggplot')
  
  expect_equal(length(one_season), 9)
  expect_equal(names(one_season), 
    c("data", "layers", "scales", "mapping", "theme", "coordinates", 
      "facet", "plot_env", "labels")             
  )
  
  p_build <- ggplot_build(one_season)
  
  expect_equal(length(p_build), 3)
  expect_equal(
    dimnames(p_build[[1]][[2]])[[2]],
    c("y", "x", "PANEL", "group")
  )
  expect_equal(sum(p_build[[1]][[5]]$x), 20744.75, tolerance=0.01)
  
})


test_that("missing START quartile example", {
  special_studentids <- c(
    "F08000002", "F08000003", "F08000004", "F08000005", "F08000008", 
    "F08000010", "F08000013", "F08000014", "F08000021", "F08000023", 
    "F08000029", "F08000036", "F08000037", "F08000044", "F08000046", 
    "F08000052", "F08000053", "F08000059", "F08000060", "F08000061", 
    "F08000062", "F08000069", "F08000086", "F08000130", "F08000160", 
    "F08000171", "F08000194", "F08000198", "F08000213", "F08000214", 
    "F08000216", "F08000217", "F08000219", "F08000222", "F08000234", 
    "F08000236", "F08000237", "F08000245", "F08000259", "F08000260", 
    "F08000261", "F08000264", "F08000265", "F08000266", "F08000267", 
    "F08000268", "F08000269", "F08000270", "F08000285", "F08000286", 
    "F08000287", "F08000288", "F08000289", "F08000292", "F08000293", 
    "F08000294", "F08000295", "F08000299", "F08000303", "F08000304", 
    "F08000308", "F08000311", "F08000314", "S08000005", "SF06000007", 
    "SF06000024", "SF06000123", "SF06000157", "SF06000361", "SF06000387", 
    "SF06000405", "SF06000566", "SF06000568", "SF06000573", "SF06000783", 
    "SF06000786", "SF06000787", "SF06001049", "SF06001226", "SF06001371", 
    "SF06001375", "SF06001380", "SF06001387", "SF07001694", "SF07001876", 
    "SF07002061", "SS07001546"
  )
  
  quart_haid <- haid_plot(
    mapvizieR_obj = mapviz,
    studentids = special_studentids,
    measurementscale = 'Mathematics',
    start_fws = 'Fall',
    start_academic_year = 2013,
    end_fws = 'Spring',
    end_academic_year = 2013
  )
  
  expect_is(quart_haid, 'gg')
  expect_is(quart_haid, 'ggplot')
  
  expect_equal(length(quart_haid), 9)
})



test_that("missing END quartile example", {
  special_studentids <- c(
    "F08000002", "F08000003", "F08000008", "F08000010", "F08000013", 
    "F08000014", "F08000021", "F08000023", "F08000029", "F08000030", 
    "F08000036", "F08000037", "F08000046", "F08000052", "F08000053", 
    "F08000059", "F08000060", "F08000061", "F08000062", "F08000069", 
    "F08000086", "F08000130", "F08000160", "F08000171", "F08000194", 
    "F08000213", "F08000214", "F08000216", "F08000217", "F08000221", 
    "F08000222", "F08000236", "F08000245", "F08000259", "F08000260", 
    "F08000261", "F08000264", "F08000265", "F08000266", "F08000267", 
    "F08000268", "F08000270", "F08000285", "F08000286", "F08000287", 
    "F08000288", "F08000289", "F08000293", "F08000294", "F08000295", 
    "F08000303", "F08000304", "F08000306", "F08000308", "F08000311", 
    "F08000313", "F08000314", "S08000005", "SF06000007", "SF06000024", 
    "SF06000123", "SF06000157", "SF06000405", "SF06000426", "SF06000566", 
    "SF06000568", "SF06000573", "SF06000783", "SF06000786", "SF06000787", 
    "SF06001049", "SF06001226", "SF06001371", "SF06001375", "SF06001380", 
    "SF06001387", "SF07001694", "SF07002061", "SS07001540", "SS07001546"
    )
  
  quart_haid <- haid_plot(
    mapvizieR_obj = mapviz,
    studentids = special_studentids,
    measurementscale = 'Mathematics',
    start_fws = 'Fall',
    start_academic_year = 2013,
    end_fws = 'Spring',
    end_academic_year = 2013
  )
  
  expect_is(quart_haid, 'gg')
  expect_is(quart_haid, 'ggplot')
  
  expect_equal(length(quart_haid), 9)
})


test_that("fuzz test haid_plot", {
  results <- fuzz_test_plot(
    'haid_plot', 
    n=10,
    additional_args=list(
      'measurementscale' = 'Reading',
      'start_fws' = 'Fall',
      'start_academic_year' = 2013,
      'end_fws' = 'Spring',
      'end_academic_year' = 2013
    )
  )
  expect_true(all(unlist(results))) 
})

