# Plot MAP Goal Strand Results

Plots a group of students' goal strand RIT scores, with each student
ranked by overall RIT score. Colors of points indicating goal strand RIT
scores indicate deviation from overall RIT score; colors of overall RIT
mark (\|) indicate national percentile rank of the overall RIT score.

## Usage

``` r
goal_strand_plot(mapvizieR_obj, studentids, measurementscale, fws, year)
```

## Arguments

- mapvizieR_obj:

  a `mapvizieR` object

- studentids:

  vector of student id numbers for students to plot

- measurementscale:

  measurementscale to plot

- fws:

  season (fall, winter, or spring) to plot

- year:

  academic year to plot

## Value

a ggplot2 object

## Details

Creates and prints a ggplot2 object showing both overall and goal strand
RIT scores for each student in a subets.

## Examples

``` r
if (FALSE) { # \dontrun{
require(dplyr)

data("ex_CombinedStudentsBySchool")
data("ex_CombinedAssessmentResults")

map_mv <- mapvizieR(ex_CombinedAssessmentResults, ex_CombinedStudentsBySchool)

ids <- ex_CombinedStudentsBySchool %>% 
  dplyr::filter(
    Grade == 8,
    SchoolName == "Mt. Bachelor Middle School",
    TermName == "Spring 2013-2014") %>% select(StudentID) %>%
    unique()

goal_strand_plot(
  map_mv, 
  studentids = c(ids[1:49, "StudentID"]), 
  measurementscale = "Mathematics", 
  fws = "Spring", 
  year = 2013
)
} # }
```
