# Visualization Functions Audit - mapvizieR

## Executive Summary

This is the **CRITICAL** analysis for a visualization package. The audit reveals that core plots are functional but use deprecated ggplot2 syntax, lack accessibility features, and have inconsistent theming. Immediate updates needed for ggplot2 3.4+ compatibility.

## 1. Core Visualization Functions Inventory

### Group Visualizations

| Function | File | Lines | Purpose |
|----------|------|-------|---------|
| `becca_plot()` | becca_plot.R | 232 | Quartile floating bar chart |
| `galloping_elephants()` | galloping_elephants.R | 145 | RIT density distributions |

### Growth Visualizations

| Function | File | Lines | Purpose |
|----------|------|-------|---------|
| `haid_plot()` | haid_plot.R | 639 | Waterfall-rainbow-arrow chart |
| `quealy_subgroups()` | quealy_subgroups.R | 338 | Subgroup change visualization |
| `goalbar()` | goalbar.R | 255 | Goal status bar chart |
| `growth_histogram()` | sgp_histogram.R | 112 | SGP distribution histogram |
| `growth_status_scatter()` | growth_status.R | 128 | Status vs growth scatter |

### Cohort/Longitudinal Visualizations

| Function | File | Lines | Purpose |
|----------|------|-------|---------|
| `cohort_cgp_hist_plot()` | cohort_cgp_hist.R | 318 | CGP histogram by cohort |
| `alt_cohort_cgp_hist_plot()` | alt_cohort_cgp_hist.R | 384 | Alternative CGP histogram |
| `cohort_longitudinal_npr_plot()` | cohort_longitudinal_plots.R | 154 | NPR over time |
| `cohort_status_trace_plot()` | cohort_status_trace_plot.R | 243 | Status percentile trace |

### Student-Level Visualizations

| Function | File | Lines | Purpose |
|----------|------|-------|---------|
| `student_npr_history_plot()` | student_npr_history_plot.R | 123 | Individual NPR history |
| `student_npr_two_term_plot()` | student_npr_two_term_plot.R | 159 | Two-term comparison |
| `build_student_college_plot()` | college_plots.R | 1268 | College readiness |
| `build_student_1year_goal_plot()` | college_plots.R | (included) | Annual goals |

### Other Visualizations

| Function | File | Lines | Purpose |
|----------|------|-------|---------|
| `strand_boxes()` | strand_boxes.R | 115 | Strand performance boxes |
| `strands_list_plot()` | strand_list_plot.R | 133 | Strand list visualization |
| `goal_strand_plot()` | goal_strand_plot.R | 163 | Strand-level goals |
| `schambach_figure()` | schambach_figure.R | 80 | Special figure type |
| `historic_nth_percentile_plot()` | historic_nth_percentile_plot.R | 104 | Historical percentile |
| `norm_plots` (various) | norm_plots.R | 113 | Norm visualization |

## 2. Individual Function Audits

### 2.1 becca_plot()

**Location**: R/becca_plot.R:28-232

**Modern ggplot2 Syntax**: Mostly OK
- Uses `aes()` correctly (not `aes_string()`)
- No deprecated aesthetics found

**Deprecation Issues**:
```r
# Line 201 - DEPRECATED
plot.margin = rep(grid::unit(0,"null"),4)
# Should use: plot.margin = margin(0, 0, 0, 0)
```

**Accessibility**:
- Colors: Uses `kipp_4col` - NOT colorblind-friendly
- No alternative text/description support

**Customizability**: Good
- `color_scheme` parameter allows customization
- `quartile_type` parameter for different calculations

**Axis Labels**: Good
- Proper x/y labels
- Scale labels present

**Documentation**: Has example but wrapped in `\dontrun{}`

**Edge Cases**:
- Missing: Handling of zero students
- Missing: Single quartile only

**Theme**: Uses `theme_bw()` with customizations - OK

**Issues Found**:
1. Hardcoded text size (line 175: `size = 4`)
2. Magic number for small_n_cutoff default (0.5)

---

### 2.2 galloping_elephants()

**Location**: R/galloping_elephants.R:18-145

**Modern ggplot2 Syntax**: Mostly OK

**Deprecation Issues**:
```r
# Line 100 - size for geom_density
geom_density(adjust = 1, size = 0.5, color = 'black')
# 'size' for line-type geoms is deprecated
# Should be: linewidth = 0.5
```

```r
# Line 115
plot.margin = rep(grid::unit(0,"null"), 4)
# DEPRECATED - use margin()
```

**Accessibility**:
- Uses `scale_fill_brewer(type = 'seq', palette = 'Blues')` - OK for colorblind
- Alpha varies by group - good for accessibility

**Customizability**: Limited
- No color customization parameter
- No size customization

**Axis Labels**: Minimal
- x-axis: RIT score (implied)
- y-axis: Density (hidden)
- Labels hidden for aesthetic

**Edge Cases**:
- Line 42: `dplyr::filter(count > 2)` - handles small groups
- `ensure_rows_in_df()` catches empty data

**Theme**: Custom transparent theme - OK

---

### 2.3 haid_plot()

**Location**: R/haid_plot.R:29-639

**CRITICAL: Extremely long function - needs refactoring**

**Modern ggplot2 Syntax**: Some issues

**Deprecation Issues**:
```r
# Line 226 - DEPRECATED
environment = .e
# The 'environment' parameter in ggplot() is deprecated
# Remove and use .data[[var]] or {{ var }} patterns
```

```r
# Multiple places - size for segments
arrow = grid::arrow(length = grid::unit(0.1,"cm"))
# This is OK for arrows
```

**Accessibility**:
- Default colors: `c("tan4", "snow4", "gold", "red")` - NOT colorblind-friendly
- Quartile colors: `c('#f3716b', '#79ac41', '#1ebdc2', '#a57eb8')` - Needs testing

**Customizability**: Excellent
- Many parameters for colors, sizes, alpha
- Growth tiers customizable

**Axis Labels**: Good
- RIT Score on x-axis
- Student ordering on y-axis (hidden)

**Edge Cases**:
- Line 78-82: Handles missing base RIT
- Handles single season vs two season

**Theme**: Complex custom theme - functional but verbose

**Major Issues**:
1. Function is 610 lines - MUST refactor
2. Uses `environment = .e` deprecated pattern
3. Uses `rbind()` which can cause issues with dplyr output (line 203)

---

### 2.4 quealy_subgroups()

**Location**: R/quealy_subgroups.R:39-338

**Modern ggplot2 Syntax**: Several issues

**Deprecation Issues**:
```r
# Line 357 - DEPRECATED dplyr
dplyr::group_by_(
  subgroup, quote(measurementscale),
  quote(start_fallwinterspring), quote(end_fallwinterspring)
)
# Must replace with group_by() using .data[[var]]
```

```r
# Line 467 - DEPRECATED
environment = e
# Remove this
```

```r
# Line 476 - Potential issue
size = 1.25  # in annotate for rect
# For rect fill outline, 'linewidth' might be needed
```

```r
# Line 546 - DEPRECATED
panel.margin = grid::unit(0, "lines")
# Should be: panel.spacing = unit(0, "lines")
```

**Accessibility**:
- Uses `'hotpink'` hardcoded - NOT appropriate
- No colorblind considerations

**Customizability**: Good
- Many parameters for subgroups, labels, etc.

**Returns**: grob (not ggplot!) - inconsistent with other functions

**Edge Cases**:
- Line 73-77: Checks for zero matching students
- Handles multiple subgroup combinations

---

### 2.5 goalbar()

**Location**: R/goalbar.R:27-255

**Modern ggplot2 Syntax**: OK

**Deprecation Issues**: None major found

**Accessibility**:
- Default colors include transparency - readable
- But not tested for colorblind accessibility

**Customizability**: Good
- Label customization
- Color customization
- Ontrack parameters

**Edge Cases**:
- Line 79: `ensure_nonzero_students_with_norms()` - handles no data

---

## 3. Deprecated ggplot2 Patterns Summary

### CRITICAL: Must Fix for ggplot2 3.4+

| Pattern | Files Affected | Replacement |
|---------|---------------|-------------|
| `size` for lines | galloping_elephants.R:100 | `linewidth` |
| `panel.margin` | quealy_subgroups.R:546 | `panel.spacing` |
| `environment` in ggplot() | haid_plot.R:226, quealy_subgroups.R:467 | Remove |
| `rep(unit(0,"null"),4)` | Multiple | `margin(0,0,0,0)` |

### Search Commands

```bash
# Find size for line geoms
grep -n "geom_line\|geom_segment\|geom_path" R/*.R | grep "size"

# Find panel.margin
grep -n "panel.margin" R/*.R

# Find environment
grep -n "environment\s*=" R/*.R

# Find deprecated unit
grep -n 'rep.*unit.*null' R/*.R
```

## 4. Color Accessibility Assessment

### Current Palettes

**KIPP Quartile Colors** (used widely):
```r
c('#f3716b', '#79ac41', '#1ebdc2', '#a57eb8')
# Salmon, Green, Teal, Purple
```

**Accessibility Check**: NEEDS TESTING with colorblind simulator

**Growth Status Colors** (haid_plot default):
```r
c("tan4", "snow4", "gold", "red")
# Brown, Gray, Yellow, Red
```

**Accessibility Check**: Red-green colorblind WILL struggle with this

### Recommendations

1. **Add viridis as dependency** for accessible defaults
2. **Create accessible palette option**:
```r
scale_fill_mapvizier_accessible <- function(...) {
  scale_fill_viridis_d(...)
}
```
3. **Document color choices** in function help

## 5. Theme Consistency Analysis

### Current Themes Used

| Function | Base Theme | Custom Elements |
|----------|------------|-----------------|
| becca_plot | theme_bw() | Grid removed, margins zeroed |
| galloping_elephants | theme_bw() | Transparent, no legend |
| haid_plot | None (custom) | Full custom transparent |
| quealy_subgroups | theme_bw() | Grid/border removed |
| goalbar | None (custom) | Minimal, no axes |

### Inconsistencies

1. Some use `theme_bw()`, others build from scratch
2. Text sizes vary: 3, 4, 5, 7, 9, 15, 18
3. Margin handling differs
4. Legend positions inconsistent

### Recommendation: Create `theme_mapvizier()`

```r
#' @export
theme_mapvizier <- function(base_size = 11, base_family = "") {
  theme_bw(base_size = base_size, base_family = base_family) +
  theme(
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.border = element_blank(),
    axis.ticks = element_line(color = "gray80"),
    strip.background = element_rect(fill = "#F4EFEB", color = NA),
    legend.key = element_rect(fill = "transparent"),
    plot.margin = margin(5, 5, 5, 5)
  )
}
```

## 6. Responsiveness and Customization

### Customization Gaps

| Function | Missing Customization |
|----------|----------------------|
| becca_plot | Text size parameter |
| galloping_elephants | Color palette, text size |
| haid_plot | Generally good |
| quealy_subgroups | Arrow colors, reference line color |
| goalbar | Font family |

### Recommended Additions

```r
# Add to all plot functions:
text_size = NULL,      # Default to theme
font_family = NULL,    # Default to theme
...                    # Pass to theme
```

## 7. Documentation Quality

### Example Output Status

| Function | Has @examples | Runs Successfully | Shows Output |
|----------|--------------|-------------------|--------------|
| becca_plot | Yes (dontrun) | Unknown | No image |
| galloping_elephants | No | N/A | N/A |
| haid_plot | No | N/A | N/A |
| quealy_subgroups | No | N/A | N/A |
| goalbar | No | N/A | N/A |

### Recommendations

1. Add working `@examples` to all visualization functions
2. Create pkgdown articles with rendered output
3. Add images to README

## 8. Edge Case Handling

### Current Coverage

| Edge Case | becca | elephants | haid | quealy | goalbar |
|-----------|-------|-----------|------|--------|---------|
| Empty data | Partial | Yes | Partial | Yes | Yes |
| Single student | No | No | Unknown | Unknown | Unknown |
| Missing values | Partial | Unknown | Yes | Unknown | Partial |
| Single term | N/A | Unknown | Yes | Unknown | N/A |
| All same quartile | Unknown | Unknown | Unknown | Unknown | Unknown |

### Recommended Tests

```r
# Add to each visualization test file:
test_that("handles empty data gracefully", {
  expect_error(
    becca_plot(mapviz, character(0), "Reading"),
    class = "mapvizier_error"
  )
})

test_that("handles single student", {
  single_id <- mapviz$roster$studentid[1]
  # Should either work or give informative error
  expect_condition(
    becca_plot(mapviz, single_id, "Reading")
  )
})
```

## 9. Summary Tables

### Modernization Status by Function

| Function | ggplot2 3.4 Ready | Accessible | Documented | Edge Cases |
|----------|-------------------|------------|------------|------------|
| becca_plot | No (margin) | No | Partial | Partial |
| galloping_elephants | No (size, margin) | Partial | No | Partial |
| haid_plot | No (environment) | No | No | Good |
| quealy_subgroups | No (multiple) | No | No | Good |
| goalbar | Yes | Partial | No | Good |

### Priority Fixes by Severity

#### Critical (ggplot2 Compatibility)

1. Replace `size` with `linewidth` for line geoms
2. Replace `panel.margin` with `panel.spacing`
3. Remove `environment` parameter from ggplot()
4. Update margin syntax

#### High (Accessibility)

1. Audit all color palettes for colorblind accessibility
2. Create accessible alternative palettes
3. Remove hardcoded `'hotpink'`

#### Medium (Usability)

1. Add working @examples
2. Standardize theme across plots
3. Add customization parameters

#### Low (Polish)

1. Create pkgdown articles with images
2. Add edge case tests
3. Refactor long functions

## 10. Specific Code Changes Required

### galloping_elephants.R

```r
# Line 100 - CHANGE:
geom_density(adjust = 1, size = 0.5, color = 'black')
# TO:
geom_density(adjust = 1, linewidth = 0.5, color = 'black')

# Line 115 - CHANGE:
plot.margin = rep(grid::unit(0,"null"), 4)
# TO:
plot.margin = margin(0, 0, 0, 0)
```

### haid_plot.R

```r
# Line 226 - REMOVE:
environment = .e
# The function should work without it in modern ggplot2
```

### quealy_subgroups.R

```r
# Line 357-360 - CHANGE:
dplyr::group_by_(
  subgroup, quote(measurementscale),
  quote(start_fallwinterspring), quote(end_fallwinterspring)
)
# TO:
dplyr::group_by(
  .data[[subgroup]], measurementscale,
  start_fallwinterspring, end_fallwinterspring
)

# Line 467 - REMOVE:
environment = e

# Line 476 - CHECK:
# If this is for rect outline, may need linewidth

# Line 546 - CHANGE:
panel.margin = grid::unit(0, "lines")
# TO:
panel.spacing = unit(0, "lines")
```

### becca_plot.R

```r
# Line 201 - CHANGE:
plot.margin = rep(grid::unit(0,"null"),4)
# TO:
plot.margin = margin(0, 0, 0, 0)
```
