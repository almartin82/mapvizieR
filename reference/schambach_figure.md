# schambach_fig

Produces list of figures from list of data.frames returned by
schambach_table_1d

## Usage

``` r
schambach_figure(
  mapvizieR_obj,
  measurementscale_in,
  studentids_in,
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

- studentids_in:

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
