# check_cdf_long

`check_cdf_long` a wrapper around a bunch of individual tests that see
if a CDF data frame conforms to mapvizieR conventions

## Usage

``` r
check_cdf_long(prepped_cdf_long)
```

## Arguments

- prepped_cdf_long:

  a map CDF file, generated either by prep_cdf_long, or via processing
  done in your data warehouse

## Value

a named list. `$boolean` has true false result; `descriptive` has a more
descriptive string describing what happened.
