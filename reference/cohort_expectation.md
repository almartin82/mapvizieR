# cohort_expectation

wrapper function to get cohort growth expectations for the lookup method

## Usage

``` r
cohort_expectation(
  measurementscale,
  end_grade,
  growth_window,
  baseline_avg_rit,
  calc_for,
  norms = 2015
)
```

## Arguments

- measurementscale:

  a MAP subject

- end_grade:

  the ENDING grade level for the growth window. ie, if this calculation
  crosses school years, use the grade level for the END of the term, per
  the example on p. 7 of the 2012 school growth study

- growth_window:

  the growth window to calculate CGP over

- baseline_avg_rit:

  mean rit at the START of the growth window

- calc_for:

  what CGPs to calculate for?

- norms:

  which school growth study to use. c(2012, 2015). default is 2015.
