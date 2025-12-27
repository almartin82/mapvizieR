# mapvizieR interface to simplify growth goal calculations

given an explicit window, or a composite baseline, will calculate CGP
targets

## Usage

``` r
mapviz_cgp_targets(
  mapvizieR_obj,
  studentids,
  measurementscale,
  start_fws,
  start_year_offset,
  end_fws,
  end_academic_year,
  end_grade,
  start_fws_prefer = NA,
  calc_for = c(1:99),
  returns = "targets",
  norms = 2015
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

  one academic season (if known); pass vector of two and
  mapviz_cgp_targets will pick

- start_year_offset:

  0 if start season is same, -1 if start is prior year.

- end_fws:

  ending season

- end_academic_year:

  ending academic year

- end_grade:

  specify the ending grade for the growth (this can't be reliably
  inferred from data).

- start_fws_prefer:

  which term is preferred? not required if only one start_fws is passed

- calc_for:

  passed through to calc_cgp, what values to calculate targets for?

- returns:

  'targets' or 'expectations'?

- norms:

  which school growth study to use. c(2012, 2015). default is 2015.

## Value

data frame of cgp targets
