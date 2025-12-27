# calc_cgp

calculates both cgp targets and cgp results.

## Usage

``` r
calc_cgp(
  measurementscale,
  end_grade,
  growth_window,
  baseline_avg_rit = NA,
  ending_avg_rit = NA,
  norms = 2015,
  calc_for = c(1:99),
  verbose = TRUE
)
```

## Arguments

- measurementscale:

  MAP subject

- end_grade:

  baseline/starting grad for the group of students

- growth_window:

  desired growth window for targets (fall/spring, spring/spring,
  fall/fall)

- baseline_avg_rit:

  the baseline mean rit for the group of students

- ending_avg_rit:

  the baseline mean rit for the group of students

- norms:

  which school growth study to use. c(2012, 2015). default is 2015.

- calc_for:

  vector of cgp targets to calculate for.

- verbose:

  should warnings about invalid seasons be raised?

## Value

a named list - targets, and results
