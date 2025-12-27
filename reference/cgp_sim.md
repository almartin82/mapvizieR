# simulate school growth at a constant CGP

simulate school growth at a constant CGP

## Usage

``` r
cgp_sim(measurementscale, start_rit, cgp, sim_over = "MS", norms = 2015)
```

## Arguments

- measurementscale:

  target subject

- start_rit:

  RIT the cohort started at

- cgp:

  what CGP to simulate growth at

- sim_over:

  'ES', 'MS' or a vector of grade levels, at least length 2

- norms:

  which school growth study to use. c(2012, 2015). default is 2015.

## Value

a named list, with grades and rits
