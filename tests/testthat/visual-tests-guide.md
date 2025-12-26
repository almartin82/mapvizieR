# Visual Regression Testing Guide

This guide explains how to use and maintain visual regression tests in the mapvizieR package.

## Overview

Visual regression tests use the `vdiffr` package to create and compare SVG snapshots of plots. This helps detect unintended visual changes when updating code or dependencies.

## Running Visual Tests

### Run all tests including visual tests

```r
# From R console in package root
devtools::test()

# From command line
R CMD check .
```

### Run only visual tests

```r
# From R console
devtools::test(filter = "visual-plots")

# Using testthat directly
library(testthat)
test_file("tests/testthat/test-visual-plots.R")
```

## Covered Plot Functions

The current visual regression test suite covers:

1. **becca_plot** - Quartile (floating bar) chart
   - Standard KIPP Report Card color scheme
   - NYS color scheme variant

2. **haid_plot** - Waterfall-rainbow-arrow chart
   - Multi-season comparison (Fall to Spring)
   - Single season variant

3. **growth_histogram** - Distribution of student growth percentiles
   - Standard grade level
   - Alternative student groups

4. **student_npr_history_plot** - Small multiples of NPR history
   - Mathematics subject
   - Reading subject

## Adding New Visual Tests

To add a new visual test:

```r
test_that("my_new_plot visual regression", {
  skip_if_not(has_test_data(), "Test data not available")

  # Create your plot
  p <- my_plot_function(
    mapvizieR_obj = mapviz,
    studentids = studentids_normal_use,
    # ... other parameters
  )

  # Verify it's a ggplot
  expect_s3_class(p, 'ggplot')

  # Create visual snapshot
  vdiffr::expect_doppelganger(
    title = "descriptive_unique_name",
    fig = p
  )
})
```

### Best Practices for Visual Tests

1. **Use stable test data**: Always use the same student IDs and parameters to ensure reproducible plots
2. **Descriptive titles**: Use clear, unique titles for snapshots (e.g., "becca_plot_mathematics_grade6_2013")
3. **Skip conditions**: Add appropriate skip conditions for missing data or packages
4. **One assertion per test**: Keep tests focused on a single plot variant
5. **Document changes**: When updating snapshots, document why in your commit message

## Managing Snapshots

### When tests fail

If visual tests fail, it could mean:

1. You intentionally changed the plot appearance (expected)
2. A dependency update changed rendering (review carefully)
3. An unintended visual regression occurred (needs fixing)

### Reviewing changes

```r
# Interactive snapshot management
vdiffr::manage_cases()

# This will open a Shiny app where you can:
# - View side-by-side comparisons
# - Accept or reject changes
# - Delete outdated snapshots
```

### Accepting new snapshots

```r
# Accept all new/changed snapshots
testthat::snapshot_accept()

# Or accept specific tests
testthat::snapshot_accept("visual-plots")
```

### Rejecting changes

If the changes are unintended:

1. Review the code changes that caused the difference
2. Fix the issue
3. Re-run the tests
4. The snapshots should now match

## Troubleshooting

### Tests are skipped

Visual tests are automatically skipped when:
- Running on CRAN (`skip_on_cran()`)
- vdiffr package is not installed
- ggplot2 package is not installed
- Test data is not available

### Platform differences

Visual tests may produce slightly different output on different platforms due to:
- Font rendering differences
- Graphics device variations
- Floating-point precision

This is why tests are skipped on CRAN. For local development, maintain snapshots on your primary development platform.

### CI/CD Integration

For continuous integration:

```yaml
# Example GitHub Actions workflow snippet
- name: Install vdiffr
  run: Rscript -e 'install.packages("vdiffr")'

- name: Run tests
  run: Rscript -e 'devtools::test()'

# Optional: Fail if snapshots changed
- name: Check for snapshot changes
  run: git diff --exit-code tests/testthat/_snaps/
```

## Technical Details

### How vdiffr works

1. Captures plot as SVG (vector format, more stable than raster)
2. Stores snapshots in `tests/testthat/_snaps/`
3. Compares new plots against stored snapshots
4. Reports differences with visual diffs

### Snapshot storage

Snapshots are stored in:
```
tests/testthat/_snaps/
  visual-plots/
    becca_plot_mathematics_grade6_2013.svg
    haid_plot_reading_fall_to_spring_2013.svg
    ...
```

### Version control

- **DO** commit snapshot files to git
- **DO** review snapshot diffs in pull requests
- **DON'T** manually edit SVG files
- **DON'T** accept snapshot changes without review

## Resources

- [vdiffr documentation](https://vdiffr.r-lib.org/)
- [testthat documentation](https://testthat.r-lib.org/)
- [Visual testing best practices](https://blog.r-hub.io/2019/05/14/vdiffr/)
