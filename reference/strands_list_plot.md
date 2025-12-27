# Creates lists of students names stacked by rank in each of a given MAP assessments goal strands

Creates lists of students names stacked by rank in each of a given MAP
assessments goal strands

## Usage

``` r
strands_list_plot(mapvizier_obj, studentids, measurement_scale, season, year)
```

## Arguments

- mapvizier_obj:

  a
  [`mapvizieR`](https://almartin82.github.io/mapvizieR/reference/mapvizieR.md)
  object

- studentids:

  a set of student ids to subset to

- measurement_scale:

  the subject to subest to

- season:

  the season to use

- year:

  academic year

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

strands_list_plot(map_mv, 
                 ids$StudentID, 
                 "Mathematics", 
                 "Fall", 
                 2013)
} # }
```
