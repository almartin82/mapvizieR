# grade_levelify_cdf

`grade_levelify_cdf` adds a student's grade level at test time to the
cdf. grade level is required for a variety of growth calculations.

## Usage

``` r
grade_levelify_cdf(prepped_cdf, roster)
```

## Arguments

- prepped_cdf:

  a cdf file that passes the checks in `check_cdf_long`

- roster:

  a roster that passes the checks in `check_roster`

## Value

a vector of grades
