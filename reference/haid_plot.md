# Chris Haid's Waterfall-Rainbow-Arrow Chart

`haid_plot` returns a ggplot object showing student MAP performance for
a group of students

## Usage

``` r
haid_plot(
  mapvizieR_obj,
  studentids,
  measurementscale,
  start_fws,
  start_academic_year,
  end_fws,
  end_academic_year,
  sort_column = "start_testritscore",
  p_growth_colors = c("tan4", "snow4", "gold", "red"),
  p_growth_tiers = c("Positive", "Typical", "College Ready", "Negative"),
  p_quartile_colors = c("#f3716b", "#79ac41", "#1ebdc2", "#a57eb8"),
  p_name_size = 3,
  p_alpha = 1,
  p_name_offset = 0.04
)
```

## Arguments

- mapvizieR_obj:

  mapvizieR object

- studentids:

  target students

- measurementscale:

  target subject

- start_fws:

  starting season

- start_academic_year:

  starting academic year

- end_fws:

  ending season

- end_academic_year:

  ending academic year

- sort_column:

  column to sort by, usually the assessments RIT scores.

- p_growth_colors:

  vector of colors passed to ggplot.

- p_growth_tiers:

  vector of colors passed to ggplot.

- p_quartile_colors:

  vector of colors passed to ggplot.

- p_name_size:

  sets point size of student names.

- p_alpha:

  sets level fo transparency for goals.

- p_name_offset:

  percentage to offset for negative names. make bigger if plot is
  smaller.

## Value

prints a ggplot object

## Details

This function builds and prints a graphic that plots MAP performance
over one or two seasons. RIT scores are color coded by percentile.
