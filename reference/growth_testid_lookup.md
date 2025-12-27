# growth_testid_lookup

a helper function for `generate_growth_df` given a scaffold of
student/season growth windows, finds the matching test data in the cdf

## Usage

``` r
growth_testid_lookup(scaffold, processed_cdf)
```

## Arguments

- scaffold:

  output of `build_growth_scaffolds`

- processed_cdf:

  conforming mapvizieR processed cdf
