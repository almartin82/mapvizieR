context("two-pager report tests")

test_that("cgp_table works", {
  ex_cgp <- cgp_table(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Reading',
    start_fws = 'Fall',
    start_academic_year = 2013,
    end_fws = 'Spring',
    end_academic_year = 2013
  )
  # Verify cgp_table returns expected structure
  expect_true("gtable" %in% class(ex_cgp) || "grob" %in% class(ex_cgp))
})


test_that("two-pager report should return ggplot object", {  
  tp_test <- two_pager(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    measurementscale = 'Reading',
    start_fws = 'Fall',
    start_academic_year = 2013,
    end_fws = 'Spring',
    end_academic_year = 2013,
    detail_academic_year = 2013
  )  
  expect_equal(length(tp_test), 2)
  expect_true("list" %in% class(tp_test))
  expect_true("gtable" %in% class(tp_test[[1]]))
  expect_true("grob" %in% class(tp_test[[1]]))
  expect_true("gDesc" %in% class(tp_test[[1]]))
})  


test_that("two-pager with KIPP report", {  
  tp_test <- two_pager(
    mapvizieR_obj = mapviz,
    studentids = mapviz[['roster']] %>% dplyr::filter(grade == 1 & map_year_academic == 2013) %>% 
      dplyr::select(studentid) %>% unlist() %>% unname() %>% as.vector(),
    measurementscale = 'Mathematics',
    start_fws = 'Fall',
    start_academic_year = 2013,
    end_fws = 'Spring',
    end_academic_year = 2013,
    detail_academic_year = 2013,
    national_data_frame = fake_kipp_data,
    replace_nat_results_match = FALSE
  )  
  expect_equal(length(tp_test), 2)
  expect_true("list" %in% class(tp_test))
  expect_true("gtable" %in% class(tp_test[[1]]))
  expect_true("grob" %in% class(tp_test[[1]]))
  expect_true("gDesc" %in% class(tp_test[[1]]))
})  


test_that("KNJ style two-pager", {  
  knj_test <- knj_two_pager(
    mapvizieR_obj = mapviz,
    studentids = mapviz[['roster']] %>% dplyr::filter(grade == 1 & map_year_academic == 2013) %>% 
      dplyr::select(studentid) %>% unlist() %>% unname() %>% as.vector(),
    measurementscale = 'Mathematics',
    end_fws = 'Spring',
    end_academic_year = 2013,
    detail_academic_year = 2013
  )  
  expect_equal(length(knj_test), 2)
  expect_true("list" %in% class(knj_test))
  expect_true("gtable" %in% class(knj_test[[1]]))
  expect_true("grob" %in% class(knj_test[[1]]))
  expect_true("gDesc" %in% class(knj_test[[1]]))
})  
