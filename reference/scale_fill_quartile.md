# Quartile Fill Scale for ggplot2

A convenience scale for applying consistent quartile colors to ggplot2
plots.

## Usage

``` r
scale_fill_quartile(..., palette = "default")
```

## Arguments

- ...:

  Arguments passed to
  [`scale_fill_manual`](https://ggplot2.tidyverse.org/reference/scale_manual.html)

- palette:

  Which palette to use: "default" or "kipp"

## Value

A ggplot2 scale object

## Examples

``` r
library(ggplot2)

df <- data.frame(quartile = factor(1:4), count = c(25, 30, 28, 17))
ggplot(df, aes(x = quartile, y = count, fill = quartile)) +
  geom_col() +
  scale_fill_quartile()

```
