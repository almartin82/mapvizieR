# Historic Recap Report

looks back across multiple cohorts. summarizes growth and and attainment

## Usage

``` r
historic_recap_report(
  mapvizieR_obj,
  studentids,
  measurementscale,
  target_percentile = 75,
  first_and_spring_only = TRUE,
  entry_grade_seasons = c(-0.8, 4.2),
  small_n_cutoff = 0.2,
  min_cohort_size = -1,
  title_text = ""
)
```

## Arguments

- mapvizieR_obj:

  conforming mapvizieR object

- studentids:

  vector of studentids

- measurementscale:

  target subject

- target_percentile:

  integer, what is the 'goal' percentile to show progress against?

- first_and_spring_only:

  logical, should we drop fall and winter scores?

- entry_grade_seasons:

  numeric vector, what are 'entry' grades to the school?

- small_n_cutoff:

  numeric, drop observations that are smaller than X cohort maximum.

- min_cohort_size:

  integer, filter out cohorts with less than this many students in them.

- title_text:

  report title

## Value

grob, with plots arranged
