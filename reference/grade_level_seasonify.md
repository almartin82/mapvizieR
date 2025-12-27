# grade_level_seasonify

`grade_level_seasonify` turns grade level into a simplified continuous
scale, using consistent offsets for MAP 'seasons'

## Usage

``` r
grade_level_seasonify(cdf)
```

## Arguments

- cdf:

  a cdf that has 'grade' and 'fallwinterspring' columns (eg product of )
  `grade_levelify()`

## Value

a data frame with a 'grade_level_season' column
