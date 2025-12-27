# mapvizieR Theme for ggplot2

A clean, consistent theme for mapvizieR visualizations based on
theme_bw(). Removes grid lines and borders for a cleaner look while
maintaining readability.

## Usage

``` r
theme_mapvizier(
  base_size = 11,
  base_family = "",
  base_line_size = base_size/22,
  base_rect_size = base_size/22
)
```

## Arguments

- base_size:

  Base font size, given in pts

- base_family:

  Base font family

- base_line_size:

  Base size for line elements

- base_rect_size:

  Base size for rect elements

## Value

A ggplot2 theme object

## Examples

``` r
library(ggplot2)

ggplot(mtcars, aes(x = wt, y = mpg)) +
  geom_point() +
  theme_mapvizier()

```
