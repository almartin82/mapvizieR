# Impute missing RIT scores

Impute missing RIT scores

## Usage

``` r
impute_rit(
  mapvizieR_obj,
  studentids,
  measurementscale,
  impute_method = "simple_average",
  interpolate_only = TRUE
)
```

## Arguments

- mapvizieR_obj:

  a mapvizieR object

- studentids:

  a vector of studentids to run

- measurementscale:

  desired subject

- impute_method:

  one of: c('simple_average')

- interpolate_only:

  should the scaffold return ALL seasons, ever, or only ones in between
  the student's first/last test?

## Value

a cdf object, with imputed rows
