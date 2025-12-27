# ny linking

ny linking

## Usage

``` r
ny_linking(
  measurementscale,
  current_grade,
  season,
  RIT,
  returns = "perf_level"
)
```

## Arguments

- measurementscale:

  MAP subject

- current_grade:

  grade level

- season:

  c('Fall', 'Winter', 'Spring')

- RIT:

  rit score

- returns:

  one of c('perf_level', 'proficient')

## Value

either character, length 1 with performance level or logical, length 1,
with proficiency
