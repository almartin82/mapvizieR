# student_scaffold

which student/test/season rows have valid data?

## Usage

``` r
student_scaffold(processed_cdf, start_season, end_season, year_offset)
```

## Arguments

- processed_cdf:

  a conforming processed_cdf data frame

- start_season:

  the start of the growth window ("Fall", "Winter", or "Spring")

- end_season:

  the end of the growth window ("Fall", "Winter", or "Spring")

- year_offset:

  start_year + ? = end_year. if same academic_year (eg fall to spring)
  this is 0 if spring to spring, this is 1

## Value

a data frame to pass back generate_growth_df that has kids, and the
relevant student/test/seasons to calculate growth records on
