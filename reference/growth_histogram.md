# growth_histogram

`growth_histogram` a simple visualization of the distribution of student
growth percentiles.

## Usage

``` r
growth_histogram(
  mapvizieR_obj,
  studentids,
  measurementscale,
  start_fws,
  start_academic_year,
  end_fws,
  end_academic_year,
  perf_breaks = c(55, 45)
)
```

## Arguments

- mapvizieR_obj:

  mapvizieR object

- studentids:

  target students

- measurementscale:

  target subject

- start_fws:

  starting season

- start_academic_year:

  starting academic year

- end_fws:

  ending season

- end_academic_year:

  ending academic year

- perf_breaks:

  growth_histogram will color the median growth percentile green,
  yellow, or red. where to break between colors? default is 55 and 45.

## Value

returns a ggplot object
