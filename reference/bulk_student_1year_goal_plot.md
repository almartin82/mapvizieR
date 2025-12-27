# Bulk generates student goal plots

Bulk generates student goal plots

## Usage

``` r
bulk_student_1year_goal_plot(
  mapvizieR_obj,
  studentids,
  measurementscale,
  labels_at_grade,
  start_grade,
  end_grade,
  growth_window,
  localization = localize("Newark"),
  aspect_ratio = 1,
  annotation_style = "small numbers",
  line_style = "gray lines",
  title_text = paste("2. What are my 2015-16 goals?", measurementscale, "\n")
)
```

## Arguments

- mapvizieR_obj:

  a conforming mapvizieR object

- studentids:

  vector of target studentids

- measurementscale:

  desired subject

- labels_at_grade:

  what grade level should the college labels print at? Generally the
  student's most recent test grade_level_season is desirable.

- start_grade:

  show student history starting with this grade level. We generally go
  back one year, to show the baseline that the goals derive from.

- end_grade:

  show student history ending with this grade level

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

- annotation_style:

  style for the underlying template. See rit_height_weight_ACT and
  rit_height_weight_npr for details.

- line_style:

  c('gray lines', 'gray dashed')

- title_text:

  what text to print above the plot?

## Value

a list of ggplot objects
