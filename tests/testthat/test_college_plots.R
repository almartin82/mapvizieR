context("college plot tests")

#make sure that constants used below exist
testing_constants()

test_that("cohort longitudinal plot with ", {
  
  bulk_hist <- bulk_student_historic_college_plot(
    mapvizieR_obj = mapviz, 
    studentids = studentids_normal_use, 
    measurementscale = 'Mathematics', 
    localization = localize('Newark'), 
    labels_at_grade = 6,
    template = 'npr',  
    aspect_ratio = 1,
    annotation_style = 'small numbers',
    line_style = 'gray lines',
    title_text = ''
  )
  
  expect_equal(length(bulk_hist), 93)
  
})