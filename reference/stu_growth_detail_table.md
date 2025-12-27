# Student Growth Detail Table

growth detail in printable format. wrapper around student_growth_detail

## Usage

``` r
stu_growth_detail_table(
  mapvizieR_obj,
  studentids,
  measurementscale,
  high_or_low_growth = "high",
  num_stu = 5,
  entry_grade_seasons = c(-0.8, 4.2),
  title = "",
  ...
)
```

## Arguments

- mapvizieR_obj:

  a conforming mapvizieR object

- studentids:

  vector of studentids

- measurementscale:

  target subject

- high_or_low_growth:

  should we list most, or least growth? default is high.

- num_stu:

  how many students to show in the table? default is 5.

- entry_grade_seasons:

  what grades are considered entry grades

- title:

  if desired, a title for the table

- ...:

  additional arguments to tableGrob

## Value

a tableGrob
