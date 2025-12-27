# cohort_mean_rit_to_npr

given a mean RIT score for a cohort, return the best match percentile
rank. (assumes the subject is grade/cohort, not a student.) only
supports 2015 norms.

## Usage

``` r
cohort_mean_rit_to_npr(measurementscale, current_grade, season, RIT)
```

## Arguments

- measurementscale:

  MAP subject

- current_grade:

  grade level

- season:

  fall winter spring

- RIT:

  mean rit score

## Value

a integer vector length one
