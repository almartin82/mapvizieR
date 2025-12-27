# helper function to calculate plot elements per-student for college plots

helper function to calculate plot elements per-student for college plots

## Usage

``` r
stu_RIT_hist_plot_elements(stu_rit_history, decode_ho = TRUE)
```

## Arguments

- stu_rit_history:

  data frame (with cdf headers) with one student

- decode_ho:

  holdovers create all kinds of funkiness. decode_ho will find apparent
  holdover events, and only return the student's second bite at that
  grade/season apple.

## Value

a list of calculations
