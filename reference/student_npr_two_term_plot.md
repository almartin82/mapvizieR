# A small multiples plot of a set of students' national percentile rank over two terms.

A small multiples plot of a set of students' national percentile rank
over two terms.

## Usage

``` r
student_npr_two_term_plot(
  mapvizieR_obj,
  studentids,
  measurementscale = "Reading",
  term_first,
  term_second,
  n_col = 9,
  min_n = 10
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

- term_first:

  the first test term. You need to use the full name, such as 'Spring
  2012-2013'

- term_second:

  the second test term. You need to use the full name, such as 'Fall
  2013-2014'

- n_col:

  number of columns to display in the plot

- min_n:

  minimum number of students required to produce the plot.

## Value

a ggplot object

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

student_npr_two_term_plot(
  map_mv,
  studentids = ids[1:80, "StudentID"],
  measurementscale ="Reading", 
  term_first = "Spring 2012-2013", 
  term_second = "Fall 2013-2014", 
  n_col = 7, 
  min_n = 5)
} # }
```
