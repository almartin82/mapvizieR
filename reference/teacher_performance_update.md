# Teacher Performance Update

a wrapper around several plots that helps show key teacher performance
statistics

## Usage

``` r
teacher_performance_update(
  mapvizieR_obj,
  studentids,
  measurementscale,
  start_fws,
  start_academic_year,
  end_fws,
  end_academic_year,
  title_text = "",
  ...
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

- title_text:

  what is this report called?

- ...:

  additional arguments

## Value

prints a ggplot object
