# Becca Vichniac's Quartile (Floating Bar) Chart

`becca_plot` returns a ggplot object binned quaritle performonce

## Usage

``` r
becca_plot(
  mapvizieR_obj,
  studentids,
  measurementscale,
  first_and_spring_only = TRUE,
  entry_grade_seasons = c(-0.8, 4.2),
  detail_academic_year = 2014,
  small_n_cutoff = 0.5,
  color_scheme = "KIPP Report Card",
  quartile_type = "kipp_quartile"
)
```

## Arguments

- mapvizieR_obj:

  mapvizieR object

- studentids:

  target students

- measurementscale:

  target subject

- first_and_spring_only:

  show all terms, or only entry & spring? default is TRUE.

- entry_grade_seasons:

  which grade_level_seasons are entry grades?

- detail_academic_year:

  don't mask any data for this academic year

- small_n_cutoff:

  drop a grade_level_season if less than x (useful when dealing with
  weird cohort histories)

- color_scheme:

  color scheme for the stacked bars. options are 'KIPP Report Card',
  'Sequential Blues', or a vector of 4 colors.

- quartile_type:

  c('KIPP Report Card', 'NYS') KIPP Report Card = traditional quartiles.
  NYS = predicted perf level on NYS test.

## Value

prints a ggplot object

## Details

This function builds and prints a bar graph with 4 bins per bar show MAP
data binned by quartile (National Percentile Rank). Bars are centered at
50th percentile horizonatally
