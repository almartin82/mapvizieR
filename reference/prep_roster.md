# prep_roster

`prep_roster` a wrapper around several roster prep functions

## Usage

``` r
prep_roster(students_by_school, kinder_codes = NULL)
```

## Arguments

- students_by_school:

  one, or multiple (combined) NWEA MAP studentsbyschool.csv file(s).

- kinder_codes:

  alternative grade codes for kindergarten (e.g., "k", "kinder",
  "Kinder") that need to be translated to grade 0. Note that code "K"
  and 13 are already checked by
  [`standardize_kinder`](https://almartin82.github.io/mapvizieR/reference/standardize_kinder.md).

## Value

a prepped roster file
