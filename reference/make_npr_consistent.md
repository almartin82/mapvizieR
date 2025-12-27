# make_npr_consistent

join a cdf to a norms study and get the empirical percentiles. protects
against longitudinal findings being clouded by changes in the norms.

## Usage

``` r
make_npr_consistent(cdf, norm_study = 2015)
```

## Arguments

- cdf:

  a mostly-processed cdf object (this is the last step) in process_cdf

- norm_study:

  c(2011, 2015). year a norm study. default is 2015. look in norm_data.R
  for documentation of available norm studies.
