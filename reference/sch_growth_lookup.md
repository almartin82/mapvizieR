# sch_growth_lookup

get cohort growth expectations via lookup from growth study

## Usage

``` r
sch_growth_lookup(
  measurementscale,
  end_grade,
  growth_window,
  baseline_avg_rit,
  norms = 2015
)
```

## Arguments

- measurementscale:

  MAP subject

- end_grade:

  grade students will be in at the end of the window

- growth_window:

  desired growth window for targets (fall/spring, spring/spring,
  fall/fall)

- baseline_avg_rit:

  the baseline mean rit for the group of students

- norms:

  which school growth study to use. c(2012, 2015). default is 2015.
