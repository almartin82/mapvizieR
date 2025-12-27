# calc_baseline_detail

given a mapvizieR object, a vector of studentids, a subject, and a
primary term, return a data frame of students and their baseline RIT
scores. also has a fallback option - for instance, imagine you were
using a prior Spring score as baseline, but if a student was a new admit
in the fall, you wanted to roll them into the baseline.

## Usage

``` r
calc_baseline_detail(
  mapvizieR_obj,
  studentids,
  measurementscale,
  primary_fws,
  primary_academic_year,
  fallback_fws = NA,
  fallback_academic_year = NA
)
```

## Arguments

- mapvizieR_obj:

  mapvizieR object

- studentids:

  target students

- measurementscale:

  target subject

- primary_fws:

  fall winter spring of primary/desired baseline

- primary_academic_year:

  academic year of primary/desired baseline

- fallback_fws:

  fall winter spring of fallback/backup baseline

- fallback_academic_year:

  academic year of fallback/backup baseline
