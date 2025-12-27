# Calculate accelerated growth from norms using a target percentile

Calculate accelerated growth from norms using a target percentile

## Usage

``` r
calc_normed_student_growth(percentile, typical_growth, sd_growth)
```

## Arguments

- percentile:

  the target percentile must be between 0 and 1 or 0 and 100

- typical_growth:

  the student's expected growth

- sd_growth:

  the standard deviation of expected growth

## Value

a numeric vector of accelerated growth

## Examples

``` r
calc_normed_student_growth(.75, 5, 2)
#> [1] 6.34898
calc_normed_student_growth(75, 5, 2) 
#> [1] 6.34898
```
