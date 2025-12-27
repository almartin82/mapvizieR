# find nearest RIT score for a student, by date

Given studentid, measurementscale, and a target_date, the function will
return the closest RIT score.

## Usage

``` r
nearest_rit(
  mapvizieR_obj,
  studentid,
  measurementscale,
  target_date,
  num_days = 180,
  forward = TRUE
)
```

## Arguments

- mapvizieR_obj:

  mapvizieR object

- studentid:

  target studentid

- measurementscale:

  target subject

- target_date:

  date of interest, `Y-m-d` format

- num_days:

  function will only return test score within num_days of target_date

- forward:

  default is TRUE, set to FALSE if only scores before target_date should
  be chosen
