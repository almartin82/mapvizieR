# generate_growth_df

`generate_growth_df` takes a CDF and given two seasons (start and end)
saturates all possible growth calculations for a student and returns a
long data frame with the results.

## Usage

``` r
generate_growth_dfs(
  processed_cdf,
  norm_df_long = norms_students_wide_to_long(student_growth_norms_2015),
  include_unsanctioned_windows = FALSE
)
```

## Arguments

- processed_cdf:

  a conforming processed_cdf data frame

- norm_df_long:

  defaults to student_growth_norms_2015 if you have a conforming norms
  object, you can use generate_growth_df to produce a growth data frame
  for those norms. example usage: calculate college ready growth norms,
  and use generate_growth_df to see if students met them.

- include_unsanctioned_windows:

  if TRUE, generate_growth_df will return some additional growth windows
  like 'Spring to Winter', which aren't in the official norms (but might
  be useful for progress monitoring).

## Value

a data frame with all rows where the student had at least ONE matching
test event (start or end)

## Details

A workflow wrapper that calls a variety of growth_df prep functions.
Given a mapvizieR processed cdf, this function will return a a growth
data frame, with one row per student per test per valid 'growth_window',
eg 'Fall to Spring'.
