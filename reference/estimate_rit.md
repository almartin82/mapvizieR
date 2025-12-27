# estimate RIT score for a student using regression or interpolation

Given studentid, measurementscale, and a target_date, the function will
return an estimated score based on selected method

## Usage

``` r
estimate_rit(
  mapvizieR_obj,
  studentid,
  measurementscale,
  target_date,
  method = c("closest", "lm", "interpolate"),
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

- method:

  which method to use to estimate RIT score

- num_days:

  function will only return test score within num_days of target_date

- forward:

  default is TRUE, set to FALSE if only scores before target_date should
  be chosen for 'closest' method
