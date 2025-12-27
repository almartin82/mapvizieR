# Longitudinal plot against NPR background

shows the progress of students, and cohort average, against the NPR
space.

## Usage

``` r
cohort_longitudinal_npr_plot(
  mapvizieR_obj,
  studentids,
  measurementscale,
  first_and_spring_only = TRUE,
  entry_grade_seasons = c(-0.8, 4.2),
  name_annotations = FALSE,
  student_alpha = 0.1,
  trace_lines = c(1, 10, 20, 30, 40, 50, 60, 70, 80, 90, 99)
)
```

## Arguments

- mapvizieR_obj:

  a conforming mapvizieR object

- studentids:

  a vector of studentids

- measurementscale:

  target subject

- first_and_spring_only:

  logical, should we include fall/winter scores from non-entry grades?

- entry_grade_seasons:

  what grades are 'entry' grades for this school?

- name_annotations:

  should we include student names on the plot? default is FALSE.

- student_alpha:

  how much to alpha-out the student observations?

- trace_lines:

  what norms to show?

## Value

a ggplot object
