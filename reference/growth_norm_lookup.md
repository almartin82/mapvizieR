# growth_norm_lookup

called by `generate_growth_df` to return growth norms for growth data
frames in process

## Usage

``` r
growth_norm_lookup(
  incomplete_growth_df,
  processed_cdf,
  norm_df_long,
  include_unsanctioned_windows,
  ...
)
```

## Arguments

- incomplete_growth_df:

  a growth df in process. needs to have growth windows, start_grade, and
  start_testritscore.

- processed_cdf:

  conforming mapvizieR processed cdf. needed for unsanctioned windows.

- norm_df_long:

  a data frame of normative expectations

- include_unsanctioned_windows:

  check generate_growth_df for a description.

- ...:

  currently not used.
