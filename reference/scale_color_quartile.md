# Quartile Color Scale for ggplot2

A convenience scale for applying consistent quartile colors to points
and lines.

## Usage

``` r
scale_color_quartile(..., palette = "default")
```

## Arguments

- ...:

  Arguments passed to
  [`scale_color_manual`](https://ggplot2.tidyverse.org/reference/scale_manual.html)

- palette:

  Which palette to use: "default" or "kipp"

## Value

A ggplot2 scale object

## Examples

``` r
library(ggplot2)

df <- data.frame(
  x = rnorm(100),
  y = rnorm(100),
  quartile = factor(sample(1:4, 100, replace = TRUE))
)
ggplot(df, aes(x = x, y = y, color = quartile)) +
  geom_point() +
  scale_color_quartile()

```
