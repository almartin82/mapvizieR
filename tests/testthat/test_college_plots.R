context("college plots tests")

#templates
test_that("npr templates generate correctly", {

  math_npr <- rit_height_weight_npr(measurementscale = 'Mathematics')
  read_npr <- rit_height_weight_npr(measurementscale = 'Reading')

  expect_is(math_npr, 'ggplot')
  expect_is(read_npr, 'ggplot')
  
  math_npr <- ggplot2::ggplot_build(math_npr)
  read_npr <- ggplot2::ggplot_build(read_npr)  
  expect_is(math_npr, 'list')
  expect_is(read_npr, 'list')
  
  expect_equal(names(math_npr), c('data', 'panel', 'plot'))
  expect_equal(names(read_npr), c('data', 'panel', 'plot'))
  
  expect_equal(
    names(math_npr[['plot']]), 
    c("data", "layers", "scales", "mapping", "theme", "coordinates", 
      "facet", "plot_env", "labels")
  )
  
  expect_equal(
    names(read_npr[['plot']]), 
    c("data", "layers", "scales", "mapping", "theme", "coordinates", 
      "facet", "plot_env", "labels")
  )
  
  expect_equal(math_npr$data[[15]]$y %>% sum(), 42906)
  expect_equal(read_npr$data[[15]]$y %>% sum(), 41356)
  
  m_goal <- npr_goal_sheet_style("Mathematics")
  expect_is(m_goal, 'ggplot')
  m_goal <- ggplot_build(m_goal)
  expect_equal(m_goal$data[[15]]$y %>% sum(), 42906)
})


test_that("npr template generates correctly with old and new norms", {
  m11 <- rit_height_weight_npr(measurementscale = 'Mathematics', norms = 2011)
  expect_is(m11, 'ggplot')
  m11 <- ggplot_build(m11)
  expect_is(m11, 'list')
  expect_equal(m11$data[[15]]$y %>% sum(), 43432)

  m15 <- rit_height_weight_npr(measurementscale = 'Mathematics', norms = 2015)
  expect_is(m15, 'ggplot')
  m15 <- ggplot_build(m15)
  expect_is(m15, 'list')
  expect_equal(m15$data[[15]]$y %>% sum(), 42906)    
})


test_that("npr templates with various options", {
  m <- rit_height_weight_npr(
    measurementscale = 'Mathematics', 
    norms = 2015,
    annotation_style = 'big numbers',
    line_style = 'gray lines'
  )
  expect_is(m, 'ggplot')
  m <- ggplot_build(m)
  expect_equal(m$data[[15]]$label %>% sum(), 10400)

  m <- rit_height_weight_npr(
    measurementscale = 'Mathematics', 
    norms = 2015,
    annotation_style = 'small numbers',
    line_style = 'gray dashed'
  )
  expect_is(m, 'ggplot')
  m <- ggplot_build(m)
  expect_equal(m$data[[15]]$label %>% sum(), 10400)   

  m <- rit_height_weight_npr(
    measurementscale = 'Mathematics', 
    norms = 2015,
    annotation_style = 'none',
    line_style = 'none'
  )
  expect_is(m, 'ggplot')
  m <- ggplot_build(m)
  expect_equal(m$data[[14]]$ymin %>% sum(), 3919)   
})


test_that("ACT templates generate correctly", {
  
  math_act <- rit_height_weight_ACT(measurementscale = 'Mathematics')
  read_act <- rit_height_weight_ACT(measurementscale = 'Reading')
  expect_is(math_act, 'ggplot')
  expect_is(read_act, 'ggplot')
  math_act <- ggplot_build(math_act)
  expect_equal(math_act$data[[9]]$y %>% sum(), 21765.1)
  read_act <- ggplot_build(read_act)
  expect_equal(read_act$data[[9]]$y %>% sum(), 21103.3)
  
  math_act <- rit_height_weight_ACT(
    measurementscale = 'Mathematics',
    annotation_style = 'big numbers',
    line_style = 'gray lines'
  )
  read_act <- rit_height_weight_ACT(
    measurementscale = 'Reading',
    annotation_style = 'big numbers',
    line_style = 'gray lines'
  )
  expect_is(math_act, 'ggplot')
  expect_is(read_act, 'ggplot')

  math_act <- rit_height_weight_ACT(
    measurementscale = 'Mathematics',
    annotation_style = 'small numbers',
    line_style = 'gray dashed'
  )
  read_act <- rit_height_weight_ACT(
    measurementscale = 'Reading',
    annotation_style = 'small numbers',
    line_style = 'gray dashed'
  )
  expect_is(math_act, 'ggplot')
  expect_is(read_act, 'ggplot')

  math_act <- rit_height_weight_ACT(
    measurementscale = 'Mathematics',
    annotation_style = 'none',
    line_style = 'none'
  )
  read_act <- rit_height_weight_ACT(
    measurementscale = 'Reading',
    annotation_style = 'none',
    line_style = 'none'
  )
  expect_is(math_act, 'ggplot')
  expect_is(read_act, 'ggplot')
  
})


test_that("bulk student historic plot with sample students", {
  
  bulk_hist <- bulk_student_historic_college_plot(
    mapvizieR_obj = mapviz, 
    studentids = studentids_normal_use[1:20], 
    measurementscale = 'Mathematics', 
    localization = localize('Newark'), 
    labels_at_grade = 6,
    template = 'npr',  
    aspect_ratio = 1,
    annotation_style = 'small numbers',
    line_style = 'gray lines',
    title_text = ''
  )
  
  expect_equal(length(bulk_hist), 20)
  expect_equal(bulk_hist[[1]]$data$RIT %>% sum(), 42906)
  
})


test_that("bulk student historic plot, ACT template", {
  
  bulk_hist <- bulk_student_historic_college_plot(
    mapvizieR_obj = mapviz, 
    studentids = studentids_normal_use[1:20], 
    measurementscale = 'Mathematics', 
    localization = localize('Newark'), 
    labels_at_grade = 6,
    template = 'ACT',  
    aspect_ratio = 1,
    annotation_style = 'small numbers',
    line_style = 'gray lines',
    title_text = ''
  )
  
  expect_equal(length(bulk_hist), 20)
  expect_equal(bulk_hist[[1]]$data$rit %>% sum(), 21765.1)
  
})


test_that("goal plot works with a sample student", {
  
  goal_ex <- build_student_1year_goal_plot(
    base_plot = npr_goal_sheet_style("Mathematics"),
    mapvizieR_obj = mapviz,
    studentid = 'F08000217',
    measurementscale = 'Mathematics',
    start_grade = 6,
    end_grade = 7,
    labels_at_grade = 6,
    growth_window = 'Spring to Spring',
    localization = localize('Newark'),
    aspect_ratio = 1
  )
  
  expect_is(goal_ex, 'ggplot')
})


test_that("bulk goal plot", {
  
  goal_ex <- bulk_student_1year_goal_plot(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use[1:20],
    measurementscale = 'Mathematics',
    labels_at_grade = 6,
    start_grade = 6,
    end_grade = 7,
    growth_window = 'Spring to Spring'
  )
  
  expect_is(goal_ex, 'list')
  expect_equal(length(goal_ex), 20)
  expect_equal(goal_ex[[1]]$data$rit %>% sum(), 21765.1)
})