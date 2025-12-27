# Cohort RIT trace plot

Cohort RIT trace plot

## Usage

``` r
cohort_rit_trace_plot(
  mapvizieR_obj,
  studentids,
  measurementscale,
  match_method = "no matching",
  first_and_spring_only = TRUE,
  entry_grade_seasons = c(-0.8, 4.2),
  collapse_schools = TRUE,
  retention_strategy = "collapse",
  small_n_cutoff = -1
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

- collapse_schools:

  treats all students as part of the same 'school' for purposes of
  plotting, so that one trajectory is shown. default is TRUE. if FALSE
  will separate lines by school and show a lengend.

- retention_strategy:

  c('collapse', 'filter_small') retained students show up as cohorts of
  1 student. collapse will run \`collapse_by_grade\` to merge those
  students into existing cohorts. \`filter_small\` will drop them from
  this visualization.

- small_n_cutoff:

  numeric, drop observations that are smaller than X cohort maximum.

## Value

a ggplot2 object
