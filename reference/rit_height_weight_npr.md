# Makes the base template that shows the RIT space and corresponding percentile rank lines.

Makes the base template that shows the RIT space and corresponding
percentile rank lines.

## Usage

``` r
rit_height_weight_npr(
  measurementscale,
  color_list = rainbow_colors(),
  ribbon_alpha = 0.35,
  annotation_style = "points",
  line_style = "none",
  spring_only = TRUE,
  norms = 2015
)
```

## Arguments

- measurementscale:

  c('Reading', 'Mathematics') - there is no linking study for Language
  or Science

- color_list:

  vector of colors to use to shade the bands. Default is the output of
  rainbow_colors().

- ribbon_alpha:

  transparency value for the background ribbons

- annotation_style:

  c('points', 'big numbers', or 'small numbers')

- line_style:

  c('gray lines')

- spring_only:

  fall norms show a 'summer slump' effect; this can be visually
  distracting. spring_only won't include those points in the reference
  lines.

- norms:

  c(2011, 2015). which norms study to use?

## Value

a ggplot object, to be used as a template for other plots
