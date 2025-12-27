# Plots mapvizieR summary object metrics longitudinally

Plots a grade-level metrics longitudinally

## Usage

``` r
summary_long_plot(
  mapvizieR_summary,
  growth_window = c("Fall to Spring"),
  by = "grade",
  metric = "pct_typical",
  school_col = "end_schoolname",
  n_cutoff = 30
)
```

## Arguments

- mapvizieR_summary:

  a `mapvizieR_summary` summary object.

- growth_window:

  growth window to plot as character vector: "Fall to Spring", "Spring
  to Spring", etc.

- by:

  character vector of whether to plot "grade" or "cohort" longitudinally

- metric:

  which column from \`mapviier_summary\` to plot longitudinally

- school_col:

  character vector specifying column name with schools' names. Defaults
  to \`end_schoolname\`

- n_cutoff:

  (default is 15), floor below which a growth calculation is ignored

## Value

a \`ggplot\` object.

## Details

Creates and prints a ggplot2 object showing line graphs of school-level
metrics by grade or cohort and and by subject over time

## Examples

``` r
if (FALSE) { # \dontrun{
require(dplyr)

data("ex_CombinedStudentsBySchool")
data("ex_CombinedAssessmentResults")

map_mv <- mapvizieR(ex_CombinedAssessmentResults, ex_CombinedStudentsBySchool)

mv_summary <- summary(map_mv)

summary_long_plot(mv_summary, metric = "pct_typical", 
growth_window = "Fall to Spring")
} # }
```
