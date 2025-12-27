# KIPP Percent Making Typ Growth Network Distribution

shows your school relative to KIPP schools nationwide (if you have that
dataset :))

## Usage

``` r
kipp_typ_growth_distro(
  nat_results_df,
  measurementscale,
  academic_year,
  grade_level,
  start_fws,
  end_fws,
  comparison_name,
  comparison_pct_typ_growth,
  replace_nat_results_match = FALSE,
  de_kippify_names = TRUE,
  de_schoolify_names = TRUE
)
```

## Arguments

- nat_results_df:

  KIPP results nationwide. Ask R&E for the raw data file - same as the
  data in the HSR tableau reports.

- measurementscale:

  MAP subject

- academic_year:

  the academic year

- grade_level:

  comparison grade level

- start_fws:

  starting season

- end_fws:

  ending season

- comparison_name:

  this school name

- comparison_pct_typ_growth:

  pct keep up, this school

- replace_nat_results_match:

  if using last year's data, remove this school's name

- de_kippify_names:

  shorten names by removing KIPP prefix

- de_schoolify_names:

  shorten names by removing 'Academy', 'Primary', etc.

## Value

a ggplot chart
