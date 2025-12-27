# Visual Tests Quick Start Guide

A quick reference for working with visual regression tests in mapvizieR.

## First Time Setup

```r
# 1. Install vdiffr if needed
install.packages("vdiffr")

# 2. Run the visual tests for the first time
source("tests/run_visual_tests.R")
# OR
testthat::test_file("tests/testthat/test-visual-plots.R")

# 3. Review the snapshot proposals
vdiffr::manage_cases()

# 4. Accept the initial snapshots
testthat::snapshot_accept()
```

## Common Tasks

### Run visual tests only

```r
devtools::test(filter = "visual-plots")
```

### Review snapshot changes interactively

```r
vdiffr::manage_cases()
```

### Accept all snapshot changes

```r
testthat::snapshot_accept()
```

### Accept changes for specific test file

```r
testthat::snapshot_accept("visual-plots")
```

### View current snapshots

Snapshots are stored as SVG files in:
```
tests/testthat/_snaps/visual-plots/
```

You can open these files in any web browser or SVG viewer.

## When Tests Fail

### Expected (you changed the plot)

1. Review the changes: `vdiffr::manage_cases()`
2. If changes look correct, accept: `testthat::snapshot_accept()`
3. Commit the updated snapshot files

### Unexpected (regression detected)

1. Review the diff: `vdiffr::manage_cases()`
2. Investigate what caused the change
3. Fix the code issue
4. Re-run tests to verify snapshots match

## What's Tested

| Plot Function | Test Cases | Description |
|--------------|------------|-------------|
| `becca_plot` | 2 | Quartile charts with different color schemes |
| `haid_plot` | 2 | Waterfall charts for single and multi-season |
| `growth_histogram` | 2 | SGP distributions for different cohorts |
| `student_npr_history_plot` | 2 | NPR history for Math and Reading |

**Total: 8 visual regression tests**

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Tests always skip | Install vdiffr: `install.packages("vdiffr")` |
| Can't find test data | Tests use data from `helper_constants.R` which loads automatically |
| Snapshots keep changing | This is normal on first run - accept them with `snapshot_accept()` |
| Platform differences | Visual tests are skipped on CRAN for this reason |

## Files Reference

- **Main test file**: `tests/testthat/test-visual-plots.R`
- **Snapshots**: `tests/testthat/_snaps/visual-plots/*.svg`
- **Full documentation**: `tests/testthat/visual-tests-guide.md`
- **Test runner**: `tests/run_visual_tests.R`

## Need More Help?

See the comprehensive guide: `tests/testthat/visual-tests-guide.md`
