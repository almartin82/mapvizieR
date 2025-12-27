# RIT distribution change (affectionately titled 'Galloping Elephants')

`galloping_elephants` returns ggplot density distributions that show
change in RIT over time

## Usage

``` r
galloping_elephants(
  mapvizieR_obj,
  studentids,
  measurementscale,
  first_and_spring_only = TRUE,
  detail_academic_year = 2014,
  entry_grade_seasons = c(-0.8, 4.2)
)
```

## Arguments

- mapvizieR_obj:

  a conforming mapvizieR object, which contains a cdf and a roster.

- studentids:

  which students to display?

- measurementscale:

  target subject

- first_and_spring_only:

  show all terms, or only entry & spring? default is TRUE.

- detail_academic_year:

  don't mask any data for this academic year

- entry_grade_seasons:

  which grade_level_seasons are entry grades?

## Value

a ggplot object.
