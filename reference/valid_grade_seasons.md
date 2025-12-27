# valid_grade_seasons

a filter on a cdf that restricts the grade_level_season ONLY to spring
data, and fall of 'entry' grades

## Usage

``` r
valid_grade_seasons(
  cdf,
  first_and_spring_only = TRUE,
  entry_grade_seasons = c(-0.8, 4.2),
  detail_academic_year = 2014
)
```

## Arguments

- cdf:

  a processed cdf

- first_and_spring_only:

  should we limit only to 'entry' grades

- entry_grade_seasons:

  which grade seasons are 'entry' for this school?

- detail_academic_year:

  what is the 'current' year? never drop data for this year.
