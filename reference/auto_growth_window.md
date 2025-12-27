# Extract likely growth window

utility function to determine the best growth window from the data
presented

## Usage

``` r
auto_growth_window(
  mapvizieR_obj,
  studentids,
  measurementscale,
  end_fws,
  end_academic_year,
  candidate_start_fws = c("Fall", "Spring"),
  candidate_year_offsets = c(0, -1),
  candidate_prefer = "Spring",
  window_tolerance = 0.5
)
```

## Arguments

- mapvizieR_obj:

  a mapvizier object

- studentids:

  the studentids in question

- measurementscale:

  a NWEA MAP measurementscale

- end_fws:

  desired end of growth term (season)

- end_academic_year:

  desired end of growth term (year)

- candidate_start_fws:

  two seasons to pick from

- candidate_year_offsets:

  if prev spring, -1

- candidate_prefer:

  which one is the 'best' term?

- window_tolerance:

  revert to the other term if this one is below the tolerance

## Value

a list with inferred start season and year
