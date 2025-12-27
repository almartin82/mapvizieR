# npr_to_rit

given a percentile rank, return the best match RIT (assumes the subject
is a student, not a school/cohort.)

## Usage

``` r
npr_to_rit(measurementscale, current_grade, season, npr, norms = 2015)
```

## Arguments

- measurementscale:

  MAP subject

- current_grade:

  grade level

- season:

  fall winter spring

- npr:

  a percentile rank, between 1-99

- norms:

  which school growth study to use. c(2012, 2015). default is 2015.

## Value

a integer vector length one
