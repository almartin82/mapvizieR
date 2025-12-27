#' @title mapvizieR Theme for ggplot2
#'
#' @description
#' A clean, consistent theme for mapvizieR visualizations based on theme_bw().
#' Removes grid lines and borders for a cleaner look while maintaining readability.
#'
#' @param base_size Base font size, given in pts
#' @param base_family Base font family
#' @param base_line_size Base size for line elements
#' @param base_rect_size Base size for rect elements
#'
#' @return A ggplot2 theme object
#'
#' @examples
#' library(ggplot2)
#'
#' ggplot(mtcars, aes(x = wt, y = mpg)) +
#'   geom_point() +
#'   theme_mapvizier()
#'
#' @export
#' @importFrom ggplot2 theme_bw theme element_blank element_line element_rect element_text margin

theme_mapvizier <- function(base_size = 11,
                            base_family = "",
                            base_line_size = base_size / 22,
                            base_rect_size = base_size / 22) {

  theme_bw(
    base_size = base_size,
    base_family = base_family,
    base_line_size = base_line_size,
    base_rect_size = base_rect_size
  ) +
    theme(
      # Remove grid lines
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),

      # Remove panel border
      panel.border = element_blank(),

      # Add subtle axis lines
      axis.line = element_line(color = "gray80", linewidth = 0.5),

      # Clean axis ticks
      axis.ticks = element_line(color = "gray80", linewidth = 0.5),

      # Strip styling for facets
      strip.background = element_rect(fill = "#F4EFEB", color = NA),
      strip.text = element_text(color = "gray30", face = "bold"),

      # Legend styling
      legend.key = element_rect(fill = "transparent", color = NA),
      legend.background = element_rect(fill = "transparent", color = NA),

      # Clean margins
      plot.margin = margin(5, 5, 5, 5),

      # Title styling
      plot.title = element_text(face = "bold", size = base_size * 1.3),
      plot.subtitle = element_text(color = "gray40"),

      # Caption styling
      plot.caption = element_text(color = "gray50", hjust = 0)
    )
}


#' @title mapvizieR Color Palettes
#'
#' @description
#' Standard color palettes used throughout mapvizieR visualizations.
#'
#' @return A character vector of color hex codes
#'
#' @examples
#' mapvizier_quartile_colors()
#' mapvizier_growth_colors()
#'
#' @name mapvizier_colors
NULL

#' @rdname mapvizier_colors
#' @export
mapvizier_quartile_colors <- function() {
  c(
    "1" = "#f3716b",
    "2" = "#79ac41",
    "3" = "#1ebdc2",
    "4" = "#a57eb8"
  )
}

#' @rdname mapvizier_colors
#' @export
mapvizier_growth_colors <- function() {
  c(
    "Negative" = "#FF0000",
    "Positive" = "#CCFF00",
    "Typical" = "#0066FF",
    "College Ready" = "#CC00FF"
  )
}

#' @rdname mapvizier_colors
#' @export
mapvizier_kipp_colors <- function() {
  # KIPP 4-color scheme for quartiles
  c(
    "#E27425",  # Orange - Q1
    "#FEBC11",  # Yellow - Q2
    "#255694",  # Blue - Q3
    "#439539"   # Green - Q4
  )
}


#' @title Quartile Fill Scale for ggplot2
#'
#' @description
#' A convenience scale for applying consistent quartile colors to ggplot2 plots.
#'
#' @param ... Arguments passed to \code{\link[ggplot2]{scale_fill_manual}}
#' @param palette Which palette to use: "default" or "kipp"
#'
#' @return A ggplot2 scale object
#'
#' @examples
#' library(ggplot2)
#'
#' df <- data.frame(quartile = factor(1:4), count = c(25, 30, 28, 17))
#' ggplot(df, aes(x = quartile, y = count, fill = quartile)) +
#'   geom_col() +
#'   scale_fill_quartile()
#'
#' @export
#' @importFrom ggplot2 scale_fill_manual

scale_fill_quartile <- function(..., palette = "default") {

  colors <- if (palette == "kipp") {
    mapvizier_kipp_colors()
  } else {
    mapvizier_quartile_colors()
  }

  scale_fill_manual(
    values = colors,
    labels = c("1st", "2nd", "3rd", "4th"),
    name = "Quartile",
    ...
  )
}


#' @title Quartile Color Scale for ggplot2
#'
#' @description
#' A convenience scale for applying consistent quartile colors to points and lines.
#'
#' @param ... Arguments passed to \code{\link[ggplot2]{scale_color_manual}}
#' @param palette Which palette to use: "default" or "kipp"
#'
#' @return A ggplot2 scale object
#'
#' @examples
#' library(ggplot2)
#'
#' df <- data.frame(
#'   x = rnorm(100),
#'   y = rnorm(100),
#'   quartile = factor(sample(1:4, 100, replace = TRUE))
#' )
#' ggplot(df, aes(x = x, y = y, color = quartile)) +
#'   geom_point() +
#'   scale_color_quartile()
#'
#' @export
#' @importFrom ggplot2 scale_color_manual

scale_color_quartile <- function(..., palette = "default") {

  colors <- if (palette == "kipp") {
    mapvizier_kipp_colors()
  } else {
    mapvizier_quartile_colors()
  }

  scale_color_manual(
    values = colors,
    labels = c("1st", "2nd", "3rd", "4th"),
    name = "Quartile",
    ...
  )
}


#' @title Growth Status Fill Scale for ggplot2
#'
#' @description
#' A convenience scale for applying consistent growth status colors.
#'
#' @param ... Arguments passed to \code{\link[ggplot2]{scale_fill_manual}}
#'
#' @return A ggplot2 scale object
#'
#' @export
#' @importFrom ggplot2 scale_fill_manual

scale_fill_growth <- function(...) {

  scale_fill_manual(
    values = mapvizier_growth_colors(),
    name = "Growth Status",
    ...
  )
}
