# Generates a one-term goal plot for one student

Generates a one-term goal plot for one student

## Usage

``` r
build_student_1year_goal_plot(
  base_plot,
  mapvizieR_obj,
  studentid,
  measurementscale,
  start_grade,
  end_grade,
  labels_at_grade,
  growth_window = "Spring to Spring",
  localization = localize("Newark"),
  aspect_ratio = 1
)
```

## Arguments

- base_plot:

  either the output of rit_height_weight_ACT, rit_height_weight_npr, or
  a wrapper around one of those templates

- mapvizieR_obj:

  a conforming mapvizieR object

- studentid:

  one target studentid

- measurementscale:

  desired subject

- start_grade:

  show student history starting with this grade level. We generally go
  back one year, to show the baseline that the goals derive from.

- end_grade:

  show student history ending with this grade level

- labels_at_grade:

  what grade level should the college labels print at? Generally the
  student's most recent test grade_level_season is desirable.

- growth_window:

  for looking up the window of SGP outcomes, what growth window should
  we use?

- localization:

  controls names/breakpoints for college labels and ACT tiers. See
  localization.R for more details

- aspect_ratio:

  college labels should print at the same angle as the act ribbons. if
  the viz is not square, this requires an adjustment. default value is
  1, 0.5 would be a rectangle 2W for 1H.

## Value

a list of ggplot objects
