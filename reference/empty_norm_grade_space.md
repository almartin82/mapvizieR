# empty norm grade space

shows the norm space across grade levels or a given subject

## Usage

``` r
empty_norm_grade_space(
  measurementscale,
  trace_lines = c(5, 10, 20, 30, 40, 50, 60, 70, 80, 90, 95),
  norms = 2015,
  norm_linetype = "solid",
  spring_only = FALSE,
  school = FALSE
)
```

## Arguments

- measurementscale:

  a NWEA map measurementscale

- trace_lines:

  vector of percentiles to show. must be between 1 and 99.

- norms:

  which norm study to use

- norm_linetype:

  any valid ggplot linetype (eg 'dashed'). default is 'solid'.

- spring_only:

  fall norms show a 'summer slump' effect; this can be visually
  distracting. spring_only won't include those points in the reference
  lines.

- school:

  if TRUE, shows school norms, not \*student\* norms
