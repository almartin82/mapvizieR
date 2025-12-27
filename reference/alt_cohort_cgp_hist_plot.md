# Shows a cohort's progress over time. Similar to cohort_cgp_hist, but uses the 2015 school grade level attainment/status norms.

Shows a cohort's progress over time. Similar to cohort_cgp_hist, but
uses the 2015 school grade level attainment/status norms.

## Usage

``` r
alt_cohort_cgp_hist_plot(
  mapvizieR_obj,
  studentids,
  measurementscale,
  match_method = "no matching",
  first_and_spring_only = TRUE,
  entry_grade_seasons = c(-0.8, 4.2),
  primary_cohort_only = TRUE,
  small_n_cutoff = 0.5,
  no_labs = FALSE,
  plot_labels = "RIT"
)
```

## Arguments

- mapvizieR_obj:

  conforming mapvizieR obj

- studentids:

  vector of studentids

- measurementscale:

  target subject

- match_method:

  do we limit to matched students, and if so, how? no matching = any
  student record in the studentids. UNIMPLEMENTED METHODS / TODO strict
  = only kids who appear in all terms strict after imputation = impute
  first, then use stritc method back one = look back one test term, and
  only include kids who can be matched

- first_and_spring_only:

  show all terms, or only entry & spring? default is TRUE.

- entry_grade_seasons:

  which grade_level_seasons are entry grades?

- primary_cohort_only:

  will determine the most frequent cohort and limit to students in that
  cohort. designed to handle discrepancies in grade/cohort pattern
  caused by previous holdovers. default is TRUE.

- small_n_cutoff:

  any cohort below this percent will get filtered out. default is 0.5,
  eg cohorts under 0.5 of max size will get dropped.

- no_labs:

  if TRUE, will not label x or y axis

- plot_labels:

  c('RIT', 'NPR'). 'RIT' is default.

## Value

a ggplot object
