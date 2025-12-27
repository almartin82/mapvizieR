# Multiple Cohort CGP histories

see cohort_cgp_hist_plot for use. Pass a vector of studentids of \*all\*
desired cohorts. Plot will facet one plot per cohort.

## Usage

``` r
alt_multi_cohort_cgp_hist_plot(
  mapvizieR_obj,
  studentids,
  measurementscale,
  match_method = "no matching",
  first_and_spring_only = TRUE,
  entry_grade_seasons = c(-0.8, 4.2),
  small_n_cutoff = 0.5,
  min_cohort_size = -1,
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

- small_n_cutoff:

  any cohort below this percent will get filtered out. default is 0.5,
  eg cohorts under 0.5 of max size will get dropped.

- min_cohort_size:

  filter cohorts with less than this many students. useful when weird
  enrollment patterns exist in your data.

- plot_labels:

  c('RIT', 'NPR'). 'RIT' is default.

## Value

a list of ggplotGrobs
