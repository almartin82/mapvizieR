# Percent of students above a given percentile, by cohort

Percent of students above a given percentile, by cohort

## Usage

``` r
historic_nth_percentile_plot(
  mapvizieR_obj,
  studentids,
  measurementscale,
  target_percentile = 75,
  first_and_spring_only = TRUE,
  entry_grade_seasons = c(-0.8, 4.2),
  small_n_cutoff = 0.5
)
```

## Arguments

- mapvizieR_obj:

  a conforming mapvizieR object

- studentids:

  vector of studentids

- measurementscale:

  target subject

- target_percentile:

  what is the goal percentile for calcs (pct of students at/above this
  percentile?)

- first_and_spring_only:

  logical, should we drop winter/fall scores?

- entry_grade_seasons:

  what seasons are entry grades?

- small_n_cutoff:

  any cohort below this percent will get filtered out. default is 0.5,
  eg cohorts under 0.5 of max size will get dropped.

## Value

a ggplot object
