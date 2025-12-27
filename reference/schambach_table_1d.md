# schambach_table

`schambach_table` Given grade level(s), shows summary table for provided
subgroups. Table includes average ending RIT, percent started in top 75
percentile growth, percent meeting "Keep Up", percent meeting "Rutgers
Ready", and the number of students in each subgroup. Named after Lindsay
Schambach, who provided initial table.

## Usage

``` r
schambach_table_1d(
  mapvizieR_obj,
  measurementscale_in,
  studentids,
  subgroup_cols = c("grade"),
  pretty_names = c("Grade"),
  start_fws,
  start_academic_year,
  end_fws,
  end_academic_year,
  complete_obsv = FALSE
)
```

## Arguments

- mapvizieR_obj:

  mapvizieR object

- measurementscale_in:

  target subject

- studentids:

  target studentids

- subgroup_cols:

  what subgroups to explore, default is by grade

- pretty_names:

  nicely formatted names for the column cuts used above.

- start_fws:

  starting season

- start_academic_year:

  starting academic year

- end_fws:

  ending season

- end_academic_year:

  ending academic year

- complete_obsv:

  if TRUE, limit only to students who have BOTH a start and end score.
  default is FALSE.
