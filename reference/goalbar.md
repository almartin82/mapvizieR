# goal_bar

a simple bar chart that shows the percentage of a cohort at different
goal states (met / didn't meet)

## Usage

``` r
goalbar(
  mapvizieR_obj,
  studentids,
  measurementscale,
  start_fws,
  start_academic_year,
  end_fws,
  end_academic_year,
  goal_labels = c(accel_growth = "Made Accel Growth", typ_growth = "Made Typ Growth",
    positive_but_not_typ = "Below Typ Growth", negative_growth = "Negative Growth",
    no_start = sprintf("Untested: %s %s", start_fws, start_academic_year), no_end =
    sprintf("Untested: %s %s", end_fws, end_academic_year)),
  goal_colors = c("#CC00FFFF", "#0066FFFF", "#CCFF00FF", "#FF0000FF", "#FFFFFF",
    "#F0FFFF"),
  ontrack_prorater = NA,
  ontrack_fws = NA,
  ontrack_academic_year = NA,
  ontrack_labels = c(ontrack_accel = "On Track for Accel Growth", ontrack_typ =
    "On Track for Typ Growth", offtrack_typ = "Off Track for Typ Growth"),
  ontrack_colors = c("#CC00FFFF", "#0066FFFF", "#CCFF00FF"),
  complete_obsv = FALSE
)
```

## Arguments

- mapvizieR_obj:

  mapvizieR object

- studentids:

  target students

- measurementscale:

  target subject

- start_fws:

  starting season

- start_academic_year:

  starting academic year

- end_fws:

  ending season

- end_academic_year:

  ending academic year

- goal_labels:

  what labels to show for each goal category. must be in order from
  highest to lowest.

- goal_colors:

  what colors to show for each goal category

- ontrack_prorater:

  default is NA. if set to a decimal value, what percent of the goal is
  considered ontrack?

- ontrack_fws:

  season to use for determining ontrack status

- ontrack_academic_year:

  year to use for determining ontrack status

- ontrack_labels:

  what labels to use for the 3 ontrack statuses

- ontrack_colors:

  what colors to use for the 3 ontrack colors

- complete_obsv:

  if TRUE, limit only to students who have BOTH a start and end score.
  default is FALSE.
