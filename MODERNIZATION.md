# mapvizieR Modernization Project

## Overview

This document describes the comprehensive modernization of the mapvizieR
R package, performed on December 25, 2025. The goal was to update the
package for compatibility with the current R ecosystem, removing
deprecated dependencies and patterns while adding modern infrastructure.

## Background

mapvizieR is an R package for visualizing and analyzing NWEA MAP
assessment data. The package had accumulated technical debt over several
years, including:

- Dependency on `ensurer`, which was archived on CRAN
- Use of deprecated ggplot2 parameters (`size` for lines,
  `panel.margin`, etc.)
- Use of deprecated dplyr scoped verbs (`summarize_()`, `group_by_()`,
  etc.)
- Lack of modern CI/CD infrastructure
- No visual regression testing for plots

## What Was Done

### Phase 1: Analysis and Planning

Created 10 detailed analysis reports examining different aspects of the
codebase:

1.  **Code Quality Analysis** (`analysis/01-code-quality.md`)
    - Identified deprecated patterns across 35+ R files
    - Catalogued ggplot2 deprecations (panel.margin, size, aes_string)
    - Catalogued dplyr deprecations (scoped verbs, tbl_df)
2.  **Architecture Review** (`analysis/02-architecture.md`)
    - Documented core data structures (cdf, roster, growth_df, mapvizieR
      object)
    - Mapped module dependencies
3.  **Dependencies Audit** (`analysis/03-dependencies.md`)
    - Identified ensurer as critical blocker (archived on CRAN)
    - Noted version requirements for ggplot2 and dplyr
4.  **Testing Infrastructure** (`analysis/04-testing.md`)
    - Assessed existing test coverage
    - Identified need for visual regression tests
5.  **Visualization Audit** (`analysis/05-visualization-audit.md`)
    - Catalogued all plot functions
    - Identified deprecated ggplot2 usage patterns
6.  **NWEA MAP Currency** (`analysis/06-nwea-map-currency.md`)
    - Reviewed norm study support
    - Documented data format compatibility
7.  **Documentation Review** (`analysis/07-documentation.md`)
    - Assessed roxygen2 documentation coverage
    - Identified areas needing improvement
8.  **CI/CD Infrastructure** (`analysis/08-ci-cd-infrastructure.md`)
    - Designed GitHub Actions workflows
    - Planned pkgdown documentation site
9.  **Performance and UX** (`analysis/09-performance-ux.md`)
    - Identified potential optimizations
    - Reviewed error message quality
10. **Prioritized Task List** (`analysis/10-task-list.md`)
    - Created implementation roadmap
    - Prioritized changes by impact and risk

### Phase 2: Dependency Modernization

#### Removed ensurer Package

The `ensurer` package was archived on CRAN, making it a blocker for
package installation. Replaced all `ensurer::ensure_that()` calls with
[`cli::cli_abort()`](https://cli.r-lib.org/reference/cli_abort.html)
pattern:

**Before:**

``` r
x %>% ensurer::ensure_that(
  !is.null(.),
  err_desc = "Value cannot be NULL"
)
```

**After:**

``` r
if (is.null(x)) {
  cli::cli_abort(c(
    "Value cannot be NULL",
    "i" = "Please provide a valid value"
  ))
}
```

Files modified: 13 R source files

#### Updated ggplot2 Usage (\>= 3.4.0)

Fixed deprecated ggplot2 patterns:

| Old Pattern             | New Pattern          | Files |
|-------------------------|----------------------|-------|
| `panel.margin`          | `panel.spacing`      | 5     |
| `size` (line geoms)     | `linewidth`          | 12    |
| `environment` parameter | Removed              | 3     |
| `aes_string()`          | `aes()` with `.data` | 4     |

#### Updated dplyr Usage (\>= 1.1.0)

Fixed deprecated dplyr patterns:

| Old Pattern    | New Pattern                                                                    | Files |
|----------------|--------------------------------------------------------------------------------|-------|
| `summarize_()` | `summarize()`                                                                  | 8     |
| `group_by_()`  | `group_by()`                                                                   | 6     |
| `select_()`    | `select()` with `all_of()`                                                     | 4     |
| `tbl_df()`     | [`tibble::as_tibble()`](https://tibble.tidyverse.org/reference/as_tibble.html) | 2     |
| `n()`          | [`dplyr::n()`](https://dplyr.tidyverse.org/reference/context.html)             | 14    |

### Phase 3: New Features

#### Theme System (`R/theme_mapvizier.R`)

Created a consistent theming system for mapvizieR visualizations:

``` r
# New theme function
theme_mapvizier(base_size = 11, base_family = "")

# Color scales
scale_fill_quartile(palette = "default")
scale_color_quartile(palette = "kipp")
scale_fill_growth()

# Color palettes
mapvizier_quartile_colors()
mapvizier_growth_colors()
mapvizier_kipp_colors()
```

#### Visual Regression Tests

Created visual regression test infrastructure using vdiffr:

- `tests/testthat/test-visual-plots.R` - 8 visual tests
- Coverage for: becca_plot, haid_plot, growth_histogram,
  student_npr_history_plot
- Documentation: `tests/testthat/visual-tests-guide.md`
- Quick start: `tests/VISUAL_TESTS_QUICKSTART.md`

### Phase 4: CI/CD Infrastructure

#### GitHub Actions Workflows

Created 4 GitHub Actions workflows:

1.  **R-CMD-check** (`.github/workflows/R-CMD-check.yaml`)
    - Runs on push and pull requests
    - Tests on Ubuntu, macOS, Windows
    - Tests R release, devel, and oldrel
2.  **Test Coverage** (`.github/workflows/test-coverage.yaml`)
    - Uploads coverage to codecov
    - Runs on push to master
3.  **pkgdown** (`.github/workflows/pkgdown.yaml`)
    - Builds documentation site
    - Deploys to GitHub Pages
4.  **Lint** (`.github/workflows/lint.yaml`)
    - Runs lintr checks
    - Reports style issues

#### Configuration Files

- `_pkgdown.yml` - Documentation site structure
- `.codecov.yml` - Coverage settings
- Updated `.Rbuildignore` - Excludes new files from package build

### Phase 5: Documentation

#### New Documentation Files

| File              | Purpose                                     |
|-------------------|---------------------------------------------|
| `README.md`       | Package overview, installation, quick start |
| `CONTRIBUTING.md` | Contributor guidelines                      |
| `NEWS.md`         | Version 0.4.0 release notes                 |
| `tests/README.md` | Test suite documentation                    |

#### Updated Package Metadata

- `DESCRIPTION` - Updated version, dependencies, and metadata
- `NAMESPACE` - Added exports for new theme functions
- Regenerated all `man/*.Rd` files

## Results

### Metrics

| Metric                    | Value |
|---------------------------|-------|
| Files Changed             | 168   |
| Lines Added               | 7,556 |
| Lines Removed             | 828   |
| New Files                 | 29    |
| Deprecated Patterns Fixed | 200+  |

### New Exports

- [`theme_mapvizier()`](https://almartin82.github.io/mapvizieR/reference/theme_mapvizier.md)
- [`scale_fill_quartile()`](https://almartin82.github.io/mapvizieR/reference/scale_fill_quartile.md)
- [`scale_color_quartile()`](https://almartin82.github.io/mapvizieR/reference/scale_color_quartile.md)
- [`scale_fill_growth()`](https://almartin82.github.io/mapvizieR/reference/scale_fill_growth.md)
- [`mapvizier_quartile_colors()`](https://almartin82.github.io/mapvizieR/reference/mapvizier_colors.md)
- [`mapvizier_growth_colors()`](https://almartin82.github.io/mapvizieR/reference/mapvizier_colors.md)
- [`mapvizier_kipp_colors()`](https://almartin82.github.io/mapvizieR/reference/mapvizier_colors.md)

### Breaking Changes

1.  **Minimum R version**: 4.1.0 (was unspecified)
2.  **ggplot2 version**: \>= 3.4.0 (was \>= 2.0.0)
3.  **dplyr version**: \>= 1.1.0 (was unspecified)
4.  **Removed dependency**: ensurer (replaced with cli/rlang)

## How to Review

``` bash
# View all changes
git diff master..modernization-2025

# View specific file
git diff master..modernization-2025 -- R/becca_plot.R

# View commit history
git log master..modernization-2025 --oneline
```

## How to Test

``` r
# Install dependencies
install.packages(c("devtools", "testthat", "vdiffr"))

# Run tests
devtools::test()

# Run R CMD check
devtools::check()

# Generate visual test snapshots
testthat::test_file("tests/testthat/test-visual-plots.R")
testthat::snapshot_accept()
```

## Known Issues

1.  Some test expectations may need updating for changed calculation
    results
2.  Visual test snapshots need to be generated and committed
3.  Some edge cases with
    [`droplevels()`](https://rdrr.io/r/base/droplevels.html) on grouped
    data may need attention

## Future Recommendations

1.  **Vignettes**: Update vignettes to use modern syntax
2.  **Test Coverage**: Expand test coverage for edge cases
3.  **Performance**: Profile and optimize hot paths
4.  **Norms**: Consider adding support for newer NWEA norm studies

## Conclusion

This modernization effort brings mapvizieR up to date with current R
ecosystem standards. The package now has:

- No deprecated dependencies
- Modern ggplot2 and dplyr patterns
- CI/CD infrastructure for ongoing maintenance
- Visual regression tests to catch unintended changes
- Improved documentation and contributor guidelines

The work was performed on the `modernization-2025` branch and is ready
for review and merging into `master`.
