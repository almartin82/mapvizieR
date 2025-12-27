# Combines a template and a mapvizieR object to create a student goal plot with college labels

Combines a template and a mapvizieR object to create a student goal plot
with college labels

## Usage

``` r
build_student_college_plot(
  base_plot,
  mapvizieR_obj,
  studentid,
  measurementscale,
  labels_at_grade,
  localization = localize("Newark"),
  aspect_ratio = 1
)
```

## Arguments

- base_plot:

  a height/weight template.

- mapvizieR_obj:

  conforming mapvizieR object

- studentid:

  target student

- measurementscale:

  target subject

- labels_at_grade:

  what grade level should the college labels print at? Generally the
  students's most recent test grade_level_season is desirable.

- localization:

  controls names/breakpoints for college labels and ACT tiers. See
  localization.R for more details

- aspect_ratio:

  college labels should print at the same angle as the act ribbons. if
  the viz is not square, this requires an adjustment. default value is
  1, 0.5 would be a rectangle 2W for 1H.

## Value

a ggplot object
