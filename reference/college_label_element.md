# abstract out the logic for writing college labels onto a template.

this was non-trivial, so it gets its own little function.

## Usage

``` r
college_label_element(
  xy_lim_list,
  measurementscale,
  labels_at_grade = 6,
  localization = localize("Newark"),
  aspect_ratio = 1,
  label_size = 5
)
```

## Arguments

- xy_lim_list:

  student max/min x and y, from stu_RIT_hist_plot_elements

- measurementscale:

  target subject

- labels_at_grade:

  what grade level should the college labels print at? Generally the
  student or cohorts's most recent test grade_level_season is desirable.

- localization:

  controls names/breakpoints for college labels and ACT tiers. See
  localization.R for more details

- aspect_ratio:

  college labels should print at the same angle as the act ribbons. if
  the viz is not square, this requires an adjustment. default value is
  1, 0.5 would be a rectangle 2W for 1H.

- label_size:

  text size for the labels. default is 5.

## Value

a ggplot geom_text object with college labels
