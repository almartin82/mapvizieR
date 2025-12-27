# mapvizieR interface to simplify CGP calculations, for one target term

given an explicit growth term (start/end), will calculate CGP

## Usage

``` r
mapviz_cgp(
  mapvizieR_obj,
  studentids,
  measurementscale,
  start_fws,
  start_academic_year,
  end_fws,
  end_academic_year,
  norms = 2015,
  use_complete_obsv = TRUE
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

- norms:

  which school growth study to use. c(2012, 2015). default is 2015.

- use_complete_obsv:

  should we only use rows that have both a beginning and ending score
  for the term being evaluated?
