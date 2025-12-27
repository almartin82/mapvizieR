# two-pager, KNJ style

similar to the existing two pager, but attempts to auto-set fall-spring
vs spring/spring

## Usage

``` r
knj_two_pager(
  mapvizieR_obj,
  studentids,
  measurementscale,
  end_fws,
  end_academic_year,
  detail_academic_year,
  candidate_start_fws = c("Fall", "Spring"),
  start_year_offsets = c(0, -1),
  prefer_fws = "Spring",
  national_data_frame = NA,
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

- end_fws:

  ending season

- end_academic_year:

  ending academic year

- detail_academic_year:

  don't mask any data for this academic year

- candidate_start_fws:

  what possible start terms should we consider?

- start_year_offsets:

  using same order as candidate_start_fws, if we pick this year, what
  should we add to the end_academic_year to get the right year's data?
  eg, -1 for spring/spring.

- prefer_fws:

  what is the 'best' start term?

- national_data_frame:

  for internal KIPP use - a data frame showing typ growth across KIPP

- title_text:

  what is this report called?

- ...:

  additional arguments

## Value

a ggplot object
