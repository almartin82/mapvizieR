context("dplyr wrappers work as expected")

group_by_ex <- mapviz$cdf %>%
  dplyr::group_by(map_year_academic, schoolname, measurementscale)

ungroup_ex <- mapviz$cdf %>%
  dplyr::ungroup()

select_ex <- mapviz$cdf %>%
  dplyr::select(termname, studentid, schoolname, measurementscale, discipline, growthmeasureyn)

test_that("group_by preserves class info", {
  expect_is(group_by_ex, 'mapvizieR_data')
  expect_is(group_by_ex, 'mapvizieR_cdf')
})

test_that("ungroup preserves class info", {
  expect_is(ungroup_ex, 'mapvizieR_data')
  expect_is(ungroup_ex, 'mapvizieR_cdf')
})

test_that("select preserves class info", {
  expect_is(select_ex, 'mapvizieR_data')
  expect_is(select_ex, 'mapvizieR_cdf')
})


