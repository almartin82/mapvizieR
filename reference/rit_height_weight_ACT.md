# Makes the base template that shows the RIT space and corresponding ACT lines using the original NWEA MAP ACT linking study

Makes the base template that shows the RIT space and corresponding ACT
lines using the original NWEA MAP ACT linking study

## Usage

``` r
rit_height_weight_ACT(
  measurementscale,
  color_list = rainbow_colors(),
  annotation_style = "points",
  line_style = "none",
  school_type = "MS",
  localization = localize("Newark")
)
```

## Arguments

- measurementscale:

  c('Reading', 'Mathematics') - there is no linking study for Language
  or Science

- color_list:

  vector of colors to use to shade the bands. Default is the output of
  rainbow_colors().

- annotation_style:

  c('points', 'big numbers', or 'small numbers')

- line_style:

  c('gray lines', 'gray dashed')

- school_type:

  c('ES', 'MS')

- localization:

  controls names/breakpoints for college labels and ACT tiers. See
  localization.R for more details

## Value

a ggplot object, to be used as a template for other plots
