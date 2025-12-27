# composite / preferred cdf baseline

given a vector of preferred baselines, will return one row per student

## Usage

``` r
preferred_cdf_baseline(
  cdf,
  start_fws,
  start_year_offset,
  end_fws,
  end_academic_year,
  start_fws_prefer
)
```

## Arguments

- cdf:

  conforming cdf

- start_fws:

  two or more seasons

- start_year_offset:

  vector of integers. 0 if start season is same, -1 if start is prior
  year.

- end_fws:

  ending season

- end_academic_year:

  ending academic year

- start_fws_prefer:

  which term is preferred?

## Value

cdf with one row per student/subject
