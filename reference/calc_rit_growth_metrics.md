# Calculate growth metrics (RIT growth, meeting indicators, conditional change in test percentile, growth index, student growth percentile).

a helper function for `generate_growth_df` which adds columns to a
growth CDF for variuos growth statistics.

## Usage

``` r
calc_rit_growth_metrics(normed_df)
```

## Arguments

- normed_df:

  a data frame that has matched growth windows for each
  student/subject/season triplet.

## Value

a data frame the same as growth_df, with additional calcs
