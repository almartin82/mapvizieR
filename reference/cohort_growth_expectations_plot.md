# Expectation distribution

Expectation distribution

## Usage

``` r
cohort_growth_expectations_plot(
  expectations_df,
  num_sd = 3,
  ref_lines = c(0.01, 0.05, 0.2, 0.5, 0.8, 0.95, 0.99),
  highlight = 0.8
)
```

## Arguments

- expectations_df:

  output of mapviz_cgp_targets - the expectations data frame

- num_sd:

  how many sds to show? default is +/- 3

- ref_lines:

  what CGP reference lines to show? default is 1, 5, 20, 50, 80, 95, 99

- highlight:

  should we highlight a reference line? set to -1 if not wanted

## Value

a ggplot object
