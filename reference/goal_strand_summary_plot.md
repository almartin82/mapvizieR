# Plot MAP Goal Strand Summary Info

Plots a group of students' average RIT scores and RIT Ranges for goal
strands.

## Usage

``` r
goal_strand_summary_plot(
  mapvizieR_obj,
  studentids,
  measurementscale,
  fws = c("Fall", "Winter", "Spring"),
  year,
  cohort = FALSE,
  spring_is_first = FALSE,
  filter_args = NULL
)
```

## Arguments

- mapvizieR_obj:

  a `mapvizieR` object

- studentids:

  vector of student id numbers for students to plot

- measurementscale:

  measurementscale to plot

- fws:

  seasons (fall, winter, or spring) as a character vector to plot

- year:

  academic year to plot

- cohort:

  cohort year to plot as integer or FALSE (the default). If \`cohort\`
  is not FALSE then \`year\` is ignored

- spring_is_first:

  logical indicating whether spring is in the given academic year or
  from the year prior.

- filter_args:

  a list of character vectors to filter \`mapvizieR_obj\$cdf\` by that
  is passed to
  [`filter`](https://dplyr.tidyverse.org/reference/filter.html)

## Value

a ggplot2 object

## Details

Creates and prints a ggplot2 object showing average and and average
range of goal strand RIT scores

## Examples

``` r
if (FALSE) { # \dontrun{
require(dplyr)

data("ex_CombinedStudentsBySchool")
data("ex_CombinedAssessmentResults")

map_mv <- mapvizieR(ex_CombinedAssessmentResults, ex_CombinedStudentsBySchool)

ids <- ex_CombinedStudentsBySchool %>%
dplyr::filter(
  TermName == "Spring 2013-2014") %>% select(StudentID) %>%
  unique()

goal_strand_summary_plot(map_mv, 
   ids$StudentID, 
   measurementscale = "Reading", 
   year = 2013, 
   cohort = 2019, 
   fws  = c("Winter", "Spring")
   )
} # }
```
