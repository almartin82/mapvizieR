# min_term_filter

returns only grade_season data where the number of students represented
is at least N

## Usage

``` r
min_term_filter(cdf, small_n_cutoff = -1)
```

## Arguments

- cdf:

  conforming cdf

- small_n_cutoff:

  anything below this percent will get filtered out. default is -1, eg
  off
