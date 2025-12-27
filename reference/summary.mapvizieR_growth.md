# summary method for `mapvizieR_growth` class

summarizes growth data from `mapvizieR_growth` object.

## Usage

``` r
# S3 method for class 'mapvizieR_growth'
summary(object, ...)
```

## Arguments

- object:

  a `mapvizieR_growth` object

- ...:

  other arguments to be passed to other functions (not currently
  supported)

## Value

summary stats as a `mapvizier_summary` object.

## Details

Creates a `mapvizier_growth_summary` object of growth data from a
`mapvizieR` object. Includes the following summarizations for every
growth term available in the `mapvizier_growth` object:

- number tested in both assessment seasons (i.e., the number of students
  who too a test in both assessment season and for which we are able to
  calcualate growth stats).

- Total students making typical growth

- Percent of students making typical growth

- Total students making college ready growth

- Percent of students making college ready growth

- Total students with NPR \>= 50 percentile in the first assessment
  season

- Percent students with NPR \>= 50 percentile in the first assessment
  season

- Total students with NPR \>= 75th percentile in the first assessment
  season

- Percent students with NPR \>= 75 percentile in the first assessment
  season

- Total students with NPR \>= 50 percentile in the second assessment
  season

- Percent students with NPR \>= 50 percentile in the second assessment
  season

- Total students with NPR \>= 75th percentile in the second assessment
  season

- Percent students with NPR \>= 75 percentile in the second assessment
  season
