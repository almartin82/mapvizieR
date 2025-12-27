# scores_by_testid

helper function for `generate_growth_df`. given a test id, returns df
with all the scores.

## Usage

``` r
scores_by_testid(testid, processed_cdf, start_or_end)
```

## Arguments

- testid:

  a vector of testids

- processed_cdf:

  a conforming processed_cdf data frame

- start_or_end:

  either c('start', 'end')

## Value

one row data frame.
