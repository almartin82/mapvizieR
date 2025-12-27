# Student growth detail

calculates longitudinal / summary growth stats for many students,
allowing analysis like 'who grew the most'? and 'who had the largest
average conditional growth percentile'?

## Usage

``` r
stu_growth_detail(
  mapvizieR_obj,
  studentids,
  measurementscale,
  entry_grade_seasons = c(-0.8, 4.2)
)
```

## Arguments

- mapvizieR_obj:

  a conforming mapvizieR object

- studentids:

  vector of studentids

- measurementscale:

  target subject

- entry_grade_seasons:

  what grades are considered entry grades

## Value

a data frame with growth data
