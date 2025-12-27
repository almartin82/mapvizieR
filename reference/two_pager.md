# MAP two-pager

KNJ style 'two pager' report that shows the progress of a grade or
cohort

## Usage

``` r
two_pager(
  mapvizieR_obj,
  studentids,
  measurementscale,
  start_fws,
  start_academic_year,
  end_fws,
  end_academic_year,
  detail_academic_year,
  national_data_frame = NA,
  title_text = "",
  entry_grade_seasons = c(-0.8, 4.2),
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

- detail_academic_year:

  don't mask any data for this academic year

- national_data_frame:

  for internal KIPP use - a data frame showing typ growth across KIPP

- title_text:

  what is this report called?

- entry_grade_seasons:

  for becca plot. default is c(-0.8, 4.2)

- ...:

  additional arguments

## Value

a list of grid graphics objects
