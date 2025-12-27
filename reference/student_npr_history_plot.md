# A small multiples plot of a set of students' national percentile rank histories.

This plots a proto-typical example of Edward Tufte's small multiples
concept. A class of students in one subject and grade is plotted, witch
each student's historical national percentile rank plotted with a simple
linear fit.

The background colors indicate the quartile the assessment earned.

## Usage

``` r
student_npr_history_plot(
  mapvizieR_obj,
  studentids,
  measurementscale,
  title_text = ""
)
```

## Arguments

- mapvizieR_obj:

  a
  [`mapvizieR`](https://almartin82.github.io/mapvizieR/reference/mapvizieR.md)
  object

- studentids:

  a set of student ids to subset to

- measurementscale:

  a MAP measurementscale

- title_text:

  title as a character vector

## Value

a ggplot2 object

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
     TermName == "Spring 2013-2014") %>% 
   dplyr::select(StudentID) %>%
   unique()

student_npr_history_plot(
  map_mv,
  studentids = ids[1:80, "StudentID"],
  measurementscale = "Reading")
} # }
```
