# Bulk generates student historic college plots

Bulk generates student historic college plots

## Usage

``` r
bulk_student_historic_college_plot(
  mapvizieR_obj,
  studentids,
  measurementscale,
  localization = localize("default"),
  labels_at_grade,
  template = "npr",
  aspect_ratio = 1,
  annotation_style = "small numbers",
  line_style = "gray lines",
  title_text = paste("1. Where have I been? ", measurementscale, "\n")
)
```

## Arguments

- mapvizieR_obj:

  a conforming mapvizieR object

- studentids:

  a vector of target studentids

- measurementscale:

  desired subject

- localization:

  controls names/breakpoints for college labels and ACT tiers. See
  localization.R for more details

- labels_at_grade:

  what grade level should the college labels print at? Generally the
  cohort's most recent test grade_level_season is desirable.

- template:

  c('npr', 'ACT'). default is npr.

- aspect_ratio:

  college labels should print at the same angle as the act ribbons. if
  the viz is not square, this requires an adjustment. default value is
  1, 0.5 would be a rectangle 2W for 1H.

- annotation_style:

  style for the underlying template. See rit_height_weight_ACT and
  rit_height_weight_npr for details.

- line_style:

  c('gray lines', 'gray dashed')

- title_text:

  what text to print above the plot?

## Value

a list of ggplot objects
