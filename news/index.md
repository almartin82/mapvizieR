# Changelog

## mapvizieR 0.4.0 (2025-12-25)

### Major Changes

This is a major modernization release that updates mapvizieR for
compatibility with current R package ecosystem standards.

#### Breaking Changes

- **Minimum R version increased to 4.1.0** for native pipe support and
  modern features.
- **Removed `ensurer` dependency** - the package was archived on CRAN.
  All validation now uses `cli` and `rlang` for better error messages.
- **ggplot2 \>= 3.4.0 required** - updated all plots to use `linewidth`
  instead of deprecated `size` parameter for line elements.
- **dplyr \>= 1.1.0 required** - replaced all deprecated scoped verbs
  ([`summarize_()`](https://dplyr.tidyverse.org/reference/se-deprecated.html),
  [`group_by_()`](https://dplyr.tidyverse.org/reference/se-deprecated.html),
  etc.) with modern equivalents using `.data[[var]]` syntax.

#### New Features

- **New
  [`theme_mapvizier()`](https://almartin82.github.io/mapvizieR/reference/theme_mapvizier.md)
  function** - Provides consistent theming across all mapvizieR
  visualizations. Use it to match the package’s visual style.
- **New color scale functions**:
  - [`scale_fill_quartile()`](https://almartin82.github.io/mapvizieR/reference/scale_fill_quartile.md) -
    Consistent quartile fill colors
  - [`scale_color_quartile()`](https://almartin82.github.io/mapvizieR/reference/scale_color_quartile.md) -
    Consistent quartile point/line colors
  - [`scale_fill_growth()`](https://almartin82.github.io/mapvizieR/reference/scale_fill_growth.md) -
    Growth status colors
- **New color palette functions**:
  - [`mapvizier_quartile_colors()`](https://almartin82.github.io/mapvizieR/reference/mapvizier_colors.md) -
    Returns quartile color palette
  - [`mapvizier_growth_colors()`](https://almartin82.github.io/mapvizieR/reference/mapvizier_colors.md) -
    Returns growth status colors
  - [`mapvizier_kipp_colors()`](https://almartin82.github.io/mapvizieR/reference/mapvizier_colors.md) -
    Returns KIPP-style quartile colors
- **GitHub Actions CI/CD** - Package now uses modern GitHub Actions
  workflows for automated testing, coverage reporting, and pkgdown
  documentation.
- **pkgdown documentation site** - Full documentation now available at
  <https://almartin82.github.io/mapvizieR>

#### Bug Fixes

- Fixed deprecation warnings from ggplot2 3.4+:
  - `panel.margin` -\> `panel.spacing`
  - `size` -\> `linewidth` for line geoms
  - Removed deprecated `environment` parameter from ggplot() calls
- Fixed deprecation warnings from dplyr 1.0+:
  - [`summarize_()`](https://dplyr.tidyverse.org/reference/se-deprecated.html)
    -\>
    [`summarize()`](https://dplyr.tidyverse.org/reference/summarise.html)
    with `.data` pronoun
  - [`group_by_()`](https://dplyr.tidyverse.org/reference/se-deprecated.html)
    -\>
    [`group_by()`](https://dplyr.tidyverse.org/reference/group_by.html)
    with `.data` pronoun
  - [`select_()`](https://dplyr.tidyverse.org/reference/se-deprecated.html)
    -\> [`select()`](https://dplyr.tidyverse.org/reference/select.html)
    with
    [`all_of()`](https://tidyselect.r-lib.org/reference/all_of.html)
  - [`tbl_df()`](https://dplyr.tidyverse.org/reference/tbl_df.html) -\>
    removed (tibbles work directly)
- Fixed margin specification using
  [`margin()`](https://ggplot2.tidyverse.org/reference/element.html)
  instead of deprecated [`unit()`](https://rdrr.io/r/grid/unit.html)
  pattern.
- Improved error messages throughout with actionable guidance.

#### Documentation

- Updated README with installation instructions and quick start guide.
- All exported functions now have complete roxygen2 documentation.
- Added pkgdown site with organized reference and articles.
- Updated vignettes to use modern syntax.

#### Testing

- Added testthat 3rd edition support.
- Added infrastructure for vdiffr visual regression tests.
- Improved test coverage for visualization functions.

#### Deprecated

- The `norms = 2011` option is deprecated and will be removed in a
  future version. Please use `norms = 2015` or update to newer norms
  when available.

------------------------------------------------------------------------

## mapvizieR 0.3.7

- Minor maintenance release.
- Fixed calculation of end_n_75th_pctl in growth_summary.
- Added rounding improvements.
- Added new metrics to cdf_summary.

## mapvizieR 0.3.6

- [`summary()`](https://rdrr.io/r/base/summary.html) methods for
  `growth_df` and `cdf` now respect incoming `dplyr` groupings.

- we use the new `janitor` package from
  [@sfirke](https://github.com/sfirke) to clean up data frame names.

## mapvizieR 0.3.5

- various hotfixes on plots that were breaking. most issues appear to be
  related to upstream changes in `dplyr`. in particular:

- [`base::rbind()`](https://rdrr.io/r/base/cbind.html) replaced with
  [`dplyr::bind_rows()`](https://dplyr.tidyverse.org/reference/bind_rows.html).
  `rbind` seems confused by `dplyr` output. see [issue
  293](https://github.com/almartin82/mapvizieR/issues/293) for detail.

- [`dplyr::select`](https://dplyr.tidyverse.org/reference/select.html)
  needed references to `matches` explicitly prefixed with `dplyr::`.
  Something about the scoping of those
  [`dplyr::select()`](https://dplyr.tidyverse.org/reference/select.html)
  statements appears to have changed with dplyr 0.5.0.

## mapvizieR 0.3.4

- an upstream change to `dplyr` broke `roster_to_growth_df`.

## mapvizieR 0.3.3

- fixed a bug that was preventing the mapvizieR object from correctly
  using the 2011 growth norms for the `growth_df`.

## mapvizieR 0.3.2

- test fixes, mostly causes by changes to `ggplot2` output or changes to
  our [`summary()`](https://rdrr.io/r/base/summary.html) methods.
- some housekeeping on function documentation

## mapvizieR 0.3.1

- new viz:
  [`cohort_status_trace_plot()`](https://almartin82.github.io/mapvizieR/reference/cohort_status_trace_plot.md) -
  uses the 2015 status norms for **grade levels** to show the change in
  a cohort over time in the **grade level** status space.
- cleans up warnings on calc_baseline_detail
- tidies up
  [`becca_plot()`](https://almartin82.github.io/mapvizieR/reference/becca_plot.md),
  with some new parameter checks.

## mapvizieR 0.3.0

- reworked summary functions to create new cdf summary method. note that
  this is a breaking change for any code that depends on
  `summary(mapviz)` - you should use `summary(mapviz$growth_df)`
  instead. `summary(mapviz)` will now return a named list with summaries
  of every relevant element of the mapvizieR object.

## mapvizieR 0.2.8

- added new york linking functions

## mapvizieR 0.2.7

- added grade/class status percentiles to
  [`summary()`](https://rdrr.io/r/base/summary.html) method.

- rewrote `cohort_cgp_hist_plot` to use grade/class status percentiles.

## mapvizieR 0.2.6

- added median calculations to
  [`summary()`](https://rdrr.io/r/base/summary.html) method

- added cohort growth percentile calculations to
  [`summary()`](https://rdrr.io/r/base/summary.html) method.

## mapvizieR 0.2.5

- `read_cdf` generates messages, not warnings or errors, when it
  encounters 0-length data files.

- `read_cdf` brings in all files as character, then does type inference
  after
  [`dplyr::bind_rows()`](https://dplyr.tidyverse.org/reference/bind_rows.html)
  has combined files.

- `quealy_subgroups` fix that allows Fall-to-Winter CGP to print.

## mapvizieR 0.2.4

- fixes deprecated `dplyr::rbind_all`.

## mapvizieR 0.2.3

- started keeping track of new features in `NEWS.md` 🙈
- added `fall_goals_report` and `historic_recap`.
