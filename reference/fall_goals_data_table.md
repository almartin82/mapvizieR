# Basline and Goals, for printing reports

Basline and Goals, for printing reports

## Usage

``` r
fall_goals_data_table(
  mapvizieR_obj,
  studentids,
  measurementscale,
  start_fws,
  start_year_offset,
  end_fws,
  end_academic_year,
  end_grade,
  start_fws_prefer = NA,
  calc_for = 80,
  output = "both",
  font_size = 20
)
```

## Arguments

- mapvizieR_obj:

  a valid mapvizieR object

- studentids:

  vector of studentids

- measurementscale:

  target subject

- start_fws:

  character, starting season for school growth norms

- start_year_offset:

  0 if start season is same, -1 if start is prior year.

- end_fws:

  ending season

- end_academic_year:

  ending academic year

- end_grade:

  grade level at end of growth window (for lookup)

- start_fws_prefer:

  if more than one start_fws, what is the preferred term?

- calc_for:

  what CGPs to calc for? vector of integers between 1:99

- output:

  c('both', 'baseline', 'goals')

- font_size:

  how big to print

## Value

gridArrange object of grobs
