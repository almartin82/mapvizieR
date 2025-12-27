# Build out the base scaffold of possible terms for every student.

Build out the base scaffold of possible terms for every student.

## Usage

``` r
imputation_scaffold(cdf, interpolate_only = TRUE)
```

## Arguments

- cdf:

  a processed cdf. assumes that there are no same student/subj/season
  dupes.

- interpolate_only:

  should the scaffold return ALL seasons, ever, or only ones in between
  the student's first/last test?

## Value

a cdf, with rows for imputation
