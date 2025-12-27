# check_processed_cdf

the mapvizieR takes a cdf + a roster and does some grade level lookup.
this function is a wrapper around some tests that make sure that the
output conforms to expectations

## Usage

``` r
check_processed_cdf(processed_cdf)
```

## Arguments

- processed_cdf:

  output of mapvizieR.default

## Value

a named list. `$boolean` has true false result; `descriptive` has a more
descriptive string describing what happened.
