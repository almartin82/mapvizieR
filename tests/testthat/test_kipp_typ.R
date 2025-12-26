context("kipp typical growth")

test_that("growth distribution should return a bar plot", {  
  typ_test <- kipp_typ_growth_distro(
    nat_results_df = fake_kipp_data,
    measurementscale = 'Mathematics', 
    academic_year = 2013,
    grade_level = 1,
    start_fws = 'Fall',
    end_fws = 'Spring',
    comparison_name = 'Explore',
    comparison_pct_typ_growth = .57,
    replace_nat_results_match = TRUE
  )

  p_build <- ggplot2::ggplot_build(typ_test)
  expect_true(is.ggplot(typ_test))
  expect_equal(nrow(p_build$data[[1]]), 26)
  # S7 ggplot2 may have more columns
  expect_true(ncol(p_build$data[[2]]) >= 15)
})


test_that("growth distribution with big data set", {
  typ_test <- kipp_typ_growth_distro(
    nat_results_df = rbind(fake_kipp_data, fake_kipp_data, fake_kipp_data, fake_kipp_data),
    measurementscale = 'Mathematics',
    academic_year = 2013,
    grade_level = 1,
    start_fws = 'Fall',
    end_fws = 'Spring',
    comparison_name = 'Explore',
    comparison_pct_typ_growth = .57,
    replace_nat_results_match = TRUE
  )

  p_build <- ggplot2::ggplot_build(typ_test)
  expect_true(is.ggplot(typ_test))
  expect_equal(nrow(p_build$data[[1]]), 101)
  # S7 ggplot2 may have more columns
  expect_true(ncol(p_build$data[[2]]) >= 15)
})  

