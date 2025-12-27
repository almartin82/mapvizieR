# rit_to_npr

given a RIT score, return the best match percentile rank. (assumes the
subject is a student, not a school/cohort.)

## Usage

``` r
rit_to_npr(measurementscale, current_grade, season, RIT, norms = 2015)
```

## Arguments

- measurementscale:

  MAP subject

- current_grade:

  grade level

- season:

  c('fall', 'winter', 'spring')

- RIT:

  rit score

- norms:

  which school growth study to use. c(2012, 2015). default is 2015.

## Value

a integer vector length one
