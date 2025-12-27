# dedupe_cdf

`dedupe_cdf` makes sure that the cdf only contains one row
student/subject/term

## Usage

``` r
dedupe_cdf(prepped_cdf, method = "NWEA")
```

## Arguments

- prepped_cdf:

  conforming prepped cdf file.

- method:

  can choose between c('NWEA', 'high RIT', 'most recent'). Default is
  NWEA method.

## Value

a data frame with one row per kid
