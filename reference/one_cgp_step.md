# wrapper to simplify CGP simulations

helps simulate what happens if a cohort grows at a constant CGP.

## Usage

``` r
one_cgp_step(
  measurementscale,
  start_rit,
  end_grade,
  cgp,
  growth_window = "Spring to Spring",
  norms = 2015
)
```

## Arguments

- measurementscale:

  target subject

- start_rit:

  mean starting rit

- end_grade:

  starting grade (not grade level season, just grade)

- cgp:

  target cgp. can be single target or vector

- growth_window:

  what growth window to step

- norms:

  which school growth study to use. c(2012, 2015). default is 2015.
