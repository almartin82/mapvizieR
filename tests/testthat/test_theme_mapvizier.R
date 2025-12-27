context("test theme_mapvizier and associated color functions")

test_that("theme_mapvizier returns a valid ggplot2 theme object", {

  theme_obj <- theme_mapvizier()

  # Test that it returns a theme object
  expect_s3_class(theme_obj, "theme")
  expect_s3_class(theme_obj, "gg")

  # Test that it has expected theme elements
  expect_true("panel.grid.major" %in% names(theme_obj))
  expect_true("panel.grid.minor" %in% names(theme_obj))
  expect_true("panel.border" %in% names(theme_obj))
  expect_true("axis.line" %in% names(theme_obj))
  expect_true("strip.background" %in% names(theme_obj))
  expect_true("legend.key" %in% names(theme_obj))
  expect_true("plot.title" %in% names(theme_obj))
})


test_that("theme_mapvizier accepts custom parameters", {

  # Test with custom base_size
  theme_large <- theme_mapvizier(base_size = 14)
  expect_s3_class(theme_large, "theme")

  # Test with custom base_family
  theme_custom_font <- theme_mapvizier(base_family = "serif")
  expect_s3_class(theme_custom_font, "theme")

  # Test with all custom parameters
  theme_custom <- theme_mapvizier(
    base_size = 16,
    base_family = "mono",
    base_line_size = 0.8,
    base_rect_size = 0.8
  )
  expect_s3_class(theme_custom, "theme")
})


test_that("theme_mapvizier can be used with ggplot2", {

  library(ggplot2)

  # Create a simple plot with theme_mapvizier
  p <- ggplot(mtcars, aes(x = wt, y = mpg)) +
    geom_point() +
    theme_mapvizier()

  expect_s3_class(p, "ggplot")

  # Check that the plot builds without errors
  expect_silent(ggplot_build(p))
})


test_that("mapvizier_quartile_colors returns correct color values", {

  colors <- mapvizier_quartile_colors()

  # Test that it returns a character vector
  expect_type(colors, "character")

  # Test that it returns exactly 4 colors
  expect_equal(length(colors), 4)

  # Test the specific color values
  expect_equal(colors[["1"]], "#f3716b")
  expect_equal(colors[["2"]], "#79ac41")
  expect_equal(colors[["3"]], "#1ebdc2")
  expect_equal(colors[["4"]], "#a57eb8")

  # Test that all colors are valid hex codes
  expect_true(all(grepl("^#[0-9a-fA-F]{6}$", colors)))

  # Test that names are correct
  expect_equal(names(colors), c("1", "2", "3", "4"))
})


test_that("mapvizier_growth_colors returns correct color values", {

  colors <- mapvizier_growth_colors()

  # Test that it returns a character vector
  expect_type(colors, "character")

  # Test that it returns exactly 4 colors
  expect_equal(length(colors), 4)

  # Test the specific color values
  expect_equal(colors[["Negative"]], "#FF0000")
  expect_equal(colors[["Positive"]], "#CCFF00")
  expect_equal(colors[["Typical"]], "#0066FF")
  expect_equal(colors[["College Ready"]], "#CC00FF")

  # Test that all colors are valid hex codes
  expect_true(all(grepl("^#[0-9a-fA-F]{6}$", colors)))

  # Test that names are correct
  expect_equal(names(colors), c("Negative", "Positive", "Typical", "College Ready"))
})


test_that("mapvizier_kipp_colors returns correct color values", {

  colors <- mapvizier_kipp_colors()

  # Test that it returns a character vector
  expect_type(colors, "character")

  # Test that it returns exactly 4 colors
  expect_equal(length(colors), 4)

  # Test the specific color values
  expect_equal(colors[[1]], "#E27425")  # Orange - Q1
  expect_equal(colors[[2]], "#FEBC11")  # Yellow - Q2
  expect_equal(colors[[3]], "#255694")  # Blue - Q3
  expect_equal(colors[[4]], "#439539")  # Green - Q4

  # Test that all colors are valid hex codes
  expect_true(all(grepl("^#[0-9a-fA-F]{6}$", colors)))
})


test_that("scale_fill_quartile returns a valid ggplot2 scale with default palette", {

  library(ggplot2)

  scale_obj <- scale_fill_quartile()

  # Test that it returns a scale object
  expect_s3_class(scale_obj, "ScaleDiscrete")
  expect_s3_class(scale_obj, "Scale")
  expect_s3_class(scale_obj, "ggproto")

  # Test that the scale has expected aesthetics
  expect_equal(scale_obj$aesthetics, "fill")

  # Create a simple plot using the scale
  df <- data.frame(quartile = factor(1:4), count = c(25, 30, 28, 17))
  p <- ggplot(df, aes(x = quartile, y = count, fill = quartile)) +
    geom_col() +
    scale_fill_quartile()

  expect_s3_class(p, "ggplot")
  expect_silent(ggplot_build(p))
})


test_that("scale_fill_quartile works with kipp palette", {

  library(ggplot2)

  scale_obj <- scale_fill_quartile(palette = "kipp")

  # Test that it returns a scale object
  expect_s3_class(scale_obj, "ScaleDiscrete")

  # Create a plot using the kipp palette
  df <- data.frame(quartile = factor(1:4), count = c(25, 30, 28, 17))
  p <- ggplot(df, aes(x = quartile, y = count, fill = quartile)) +
    geom_col() +
    scale_fill_quartile(palette = "kipp")

  expect_s3_class(p, "ggplot")
  expect_silent(ggplot_build(p))
})


test_that("scale_fill_quartile accepts additional arguments", {

  library(ggplot2)

  # Test with guide argument
  scale_obj <- scale_fill_quartile(guide = "legend")
  expect_s3_class(scale_obj, "ScaleDiscrete")

  # Test that it works in a plot with additional arguments
  df <- data.frame(quartile = factor(1:4), count = c(25, 30, 28, 17))
  p <- ggplot(df, aes(x = quartile, y = count, fill = quartile)) +
    geom_col() +
    scale_fill_quartile(guide = guide_legend(reverse = TRUE))

  expect_s3_class(p, "ggplot")
  expect_silent(ggplot_build(p))
})


test_that("scale_color_quartile returns a valid ggplot2 scale with default palette", {

  library(ggplot2)

  scale_obj <- scale_color_quartile()

  # Test that it returns a scale object
  expect_s3_class(scale_obj, "ScaleDiscrete")
  expect_s3_class(scale_obj, "Scale")
  expect_s3_class(scale_obj, "ggproto")

  # Test that the scale has expected aesthetics
  expect_equal(scale_obj$aesthetics, "colour")

  # Create a simple plot using the scale
  df <- data.frame(
    x = rnorm(40),
    y = rnorm(40),
    quartile = factor(rep(1:4, each = 10))
  )
  p <- ggplot(df, aes(x = x, y = y, color = quartile)) +
    geom_point() +
    scale_color_quartile()

  expect_s3_class(p, "ggplot")
  expect_silent(ggplot_build(p))
})


test_that("scale_color_quartile works with kipp palette", {

  library(ggplot2)

  scale_obj <- scale_color_quartile(palette = "kipp")

  # Test that it returns a scale object
  expect_s3_class(scale_obj, "ScaleDiscrete")

  # Create a plot using the kipp palette
  df <- data.frame(
    x = rnorm(40),
    y = rnorm(40),
    quartile = factor(rep(1:4, each = 10))
  )
  p <- ggplot(df, aes(x = x, y = y, color = quartile)) +
    geom_point() +
    scale_color_quartile(palette = "kipp")

  expect_s3_class(p, "ggplot")
  expect_silent(ggplot_build(p))
})


test_that("scale_color_quartile accepts additional arguments", {

  library(ggplot2)

  # Test with guide argument
  scale_obj <- scale_color_quartile(guide = "legend")
  expect_s3_class(scale_obj, "ScaleDiscrete")

  # Test that it works in a plot with additional arguments
  df <- data.frame(
    x = rnorm(40),
    y = rnorm(40),
    quartile = factor(rep(1:4, each = 10))
  )
  p <- ggplot(df, aes(x = x, y = y, color = quartile)) +
    geom_point() +
    scale_color_quartile(guide = guide_legend(reverse = TRUE))

  expect_s3_class(p, "ggplot")
  expect_silent(ggplot_build(p))
})


test_that("scale_fill_growth returns a valid ggplot2 scale", {

  library(ggplot2)

  scale_obj <- scale_fill_growth()

  # Test that it returns a scale object
  expect_s3_class(scale_obj, "ScaleDiscrete")
  expect_s3_class(scale_obj, "Scale")
  expect_s3_class(scale_obj, "ggproto")

  # Test that the scale has expected aesthetics
  expect_equal(scale_obj$aesthetics, "fill")

  # Create a simple plot using the scale
  df <- data.frame(
    status = factor(
      c("Negative", "Positive", "Typical", "College Ready"),
      levels = c("Negative", "Positive", "Typical", "College Ready")
    ),
    count = c(10, 20, 30, 15)
  )
  p <- ggplot(df, aes(x = status, y = count, fill = status)) +
    geom_col() +
    scale_fill_growth()

  expect_s3_class(p, "ggplot")
  expect_silent(ggplot_build(p))
})


test_that("scale_fill_growth accepts additional arguments", {

  library(ggplot2)

  # Test with guide argument
  scale_obj <- scale_fill_growth(guide = "legend")
  expect_s3_class(scale_obj, "ScaleDiscrete")

  # Test that it works in a plot with custom labels
  df <- data.frame(
    status = factor(
      c("Negative", "Positive", "Typical", "College Ready"),
      levels = c("Negative", "Positive", "Typical", "College Ready")
    ),
    count = c(10, 20, 30, 15)
  )
  p <- ggplot(df, aes(x = status, y = count, fill = status)) +
    geom_col() +
    scale_fill_growth()

  expect_s3_class(p, "ggplot")
  expect_silent(ggplot_build(p))
})


test_that("color palettes are consistent across functions", {

  # Get default quartile colors from the palette function
  quartile_colors <- mapvizier_quartile_colors()

  # Create a plot and extract the colors from scale_fill_quartile
  library(ggplot2)
  df <- data.frame(quartile = factor(1:4), count = c(25, 30, 28, 17))
  p <- ggplot(df, aes(x = quartile, y = count, fill = quartile)) +
    geom_col() +
    scale_fill_quartile()

  built_plot <- ggplot_build(p)
  used_colors <- built_plot$data[[1]]$fill

  # Test that the colors match
  expect_equal(used_colors, unname(quartile_colors))
})


test_that("kipp palette is consistent across functions", {

  # Get KIPP colors from the palette function
  kipp_colors <- mapvizier_kipp_colors()

  # Create a plot and extract the colors from scale_fill_quartile with kipp palette
  library(ggplot2)
  df <- data.frame(quartile = factor(1:4), count = c(25, 30, 28, 17))
  p <- ggplot(df, aes(x = quartile, y = count, fill = quartile)) +
    geom_col() +
    scale_fill_quartile(palette = "kipp")

  built_plot <- ggplot_build(p)
  used_colors <- built_plot$data[[1]]$fill

  # Test that the colors match
  expect_equal(used_colors, unname(kipp_colors))
})


test_that("growth palette is consistent across functions", {

  # Get growth colors from the palette function
  growth_colors <- mapvizier_growth_colors()

  # Create a plot and extract the colors from scale_fill_growth
  library(ggplot2)
  df <- data.frame(
    status = factor(
      c("Negative", "Positive", "Typical", "College Ready"),
      levels = c("Negative", "Positive", "Typical", "College Ready")
    ),
    count = c(10, 20, 30, 15)
  )
  p <- ggplot(df, aes(x = status, y = count, fill = status)) +
    geom_col() +
    scale_fill_growth()

  built_plot <- ggplot_build(p)
  used_colors <- built_plot$data[[1]]$fill

  # Test that the colors match
  expect_equal(used_colors, unname(growth_colors))
})
