# mapvizieR Modernization Task List

## Overview

This document consolidates all findings from the analysis reports into a prioritized, actionable task list. Tasks are organized by priority and include specific files, changes required, and complexity estimates.

**Complexity Key:**
- **S (Small)**: < 30 minutes, single file change
- **M (Medium)**: 1-2 hours, multiple related changes
- **L (Large)**: 2+ hours, significant refactoring or multiple files

---

## Priority 1: Critical (Breaking/Blocking Issues)

These issues prevent the package from being installed or cause immediate failures.

### 1.1 Remove ensurer Dependency (CRAN Archived)

**Files**: Multiple
**Complexity**: M
**Why**: ensurer is archived on CRAN - package won't install

| File | Line(s) | Change |
|------|---------|--------|
| DESCRIPTION | Imports | Remove ensurer, add cli, rlang |
| R/mapvizieR_object.R | 120-126 | Replace `ensures_that` with rlang pattern |
| R/util.R | 782-800 | Replace `ensures_that` with rlang pattern |
| R/quealy_subgroups.R | 74-77, 157-158, 221-222 | Replace `ensure_that` with cli::cli_abort |
| R/becca_plot.R | 44-49 | Replace `ensure_that` with cli::cli_abort |
| R/roster_to_df.R | ~40, ~80 | Replace `ensure_that` with cli::cli_abort |
| R/goals_and_projections.R | ~50 | Replace `ensure_that` with cli::cli_abort |

**Replacement Pattern**:
```r
# OLD
df %>% ensurer::ensure_that(nrow(.) > 0 ~ "no students")

# NEW
if (nrow(df) == 0) {
  cli::cli_abort("no matching students for the specified subject/terms")
}
```

### 1.2 Delete Deprecated wercker.yml

**File**: wercker.yml
**Complexity**: S
**Why**: Non-functional, wercker service is defunct

```bash
rm wercker.yml
```

### 1.3 Create GitHub Actions CI

**Files**: .github/workflows/*
**Complexity**: M
**Why**: No working CI exists

- [ ] Create `.github/workflows/R-CMD-check.yaml`
- [ ] Create `.github/workflows/test-coverage.yaml`
- [ ] Create `.github/workflows/pkgdown.yaml`
- [ ] Create `.github/workflows/lint.yaml`

### 1.4 Update DESCRIPTION

**File**: DESCRIPTION
**Complexity**: S
**Why**: Outdated metadata, missing fields, archived dependency

Changes:
- [ ] Remove ensurer from Imports
- [ ] Add cli (>= 3.0.0) to Imports
- [ ] Add rlang (>= 1.0.0) to Imports
- [ ] Update R version requirement to >= 4.1.0
- [ ] Fix typo: "mapzivieR" -> "mapvizieR"
- [ ] Add URL field
- [ ] Add BugReports field
- [ ] Update RoxygenNote to current version

---

## Priority 2: High (ggplot2/tidyverse Compatibility)

These cause deprecation warnings or failures with current package versions.

### 2.1 Fix ggplot2 Deprecations

**Complexity**: M per file
**Why**: Causes warnings/errors with ggplot2 >= 3.4.0

| File | Line | Old | New |
|------|------|-----|-----|
| R/galloping_elephants.R | 100 | `size = 0.5` | `linewidth = 0.5` |
| R/galloping_elephants.R | 115 | `rep(grid::unit(0,"null"), 4)` | `margin(0, 0, 0, 0)` |
| R/becca_plot.R | 201 | `rep(grid::unit(0,"null"),4)` | `margin(0, 0, 0, 0)` |
| R/quealy_subgroups.R | 546 | `panel.margin` | `panel.spacing` |
| R/haid_plot.R | 226 | `environment = .e` | (remove) |
| R/quealy_subgroups.R | 467 | `environment = e` | (remove) |

### 2.2 Fix Deprecated dplyr Scoped Verbs

**Complexity**: L
**Why**: Deprecated in dplyr 1.0+

| File | Line(s) | Function | Replacement |
|------|---------|----------|-------------|
| R/haid_plot.R | 680-686 | `summarize_()` | `summarize()` with `.data` |
| R/quealy_subgroups.R | 357-360 | `group_by_()` | `group_by()` with `.data` |
| R/util.R | 644-665 | `select_()`, `group_by_()` | Modern equivalents |
| R/util.R | 46 | `dplyr::tbl_df()` | `tibble::as_tibble()` |

**Pattern**:
```r
# OLD
dplyr::group_by_(subgroup, quote(measurementscale))

# NEW
dplyr::group_by(.data[[subgroup]], measurementscale)
```

### 2.3 Remove reshape2 Dependency

**File**: DESCRIPTION + code files
**Complexity**: M
**Why**: reshape2 is superseded by tidyr

- [ ] Search for `reshape2::` usage
- [ ] Replace `melt()` with `pivot_longer()`
- [ ] Replace `dcast()` with `pivot_wider()`
- [ ] Remove reshape2 from DESCRIPTION

### 2.4 Update NAMESPACE Imports

**File**: R files with roxygen
**Complexity**: S
**Why**: Proper imports needed

- [ ] Add `@importFrom rlang abort .data`
- [ ] Add `@importFrom cli cli_abort cli_warn`
- [ ] Run `devtools::document()`

---

## Priority 3: Medium (Code Quality/Testing)

These improve maintainability and reliability.

### 3.1 Add testthat 3rd Edition

**Files**: DESCRIPTION, tests/testthat.R
**Complexity**: S
**Why**: Access to modern testing features

- [ ] Add `Config/testthat/edition: 3` to DESCRIPTION
- [ ] Update testthat minimum version to 3.0.0
- [ ] Remove deprecated `context()` calls from test files

### 3.2 Add Visual Regression Tests (vdiffr)

**Files**: tests/testthat/test-visual-*.R
**Complexity**: M
**Why**: Critical for visualization package

- [ ] Add vdiffr to Suggests
- [ ] Create `test-visual-becca.R`
- [ ] Create `test-visual-haid.R`
- [ ] Create `test-visual-elephants.R`
- [ ] Create `test-visual-quealy.R`
- [ ] Generate initial snapshots

### 3.3 Add Input Validation to Visualization Functions

**Files**: R/becca_plot.R, R/haid_plot.R, etc.
**Complexity**: M per function
**Why**: Better user experience, catches errors early

Add validation for:
- [ ] studentids exist in data
- [ ] measurementscale is valid
- [ ] Academic years/terms exist
- [ ] Color vectors are correct length

### 3.4 Create Centralized Theme

**File**: R/theme_mapvizier.R (new)
**Complexity**: M
**Why**: Consistency, DRY principle

```r
#' @export
theme_mapvizier <- function(base_size = 11) {
  theme_bw(base_size = base_size) +
  theme(
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.border = element_blank(),
    # ... standard styling
  )
}

#' @export
scale_fill_quartile <- function(...) {
  scale_fill_manual(
    values = c('#f3716b', '#79ac41', '#1ebdc2', '#a57eb8'),
    ...
  )
}
```

### 3.5 Split util.R (866 lines)

**Files**: R/util.R -> multiple files
**Complexity**: M
**Why**: File is too large, hard to maintain

Split into:
- [ ] R/validate.R (validation functions)
- [ ] R/helpers.R (general helpers)
- [ ] R/filter.R (filtering functions)
- [ ] R/colors.R (color-related functions)

### 3.6 Fix Hardcoded Years

**Files**: R/becca_plot.R, others
**Complexity**: S
**Why**: 2014 is very outdated as default

```r
# Change
detail_academic_year = 2014
# To
detail_academic_year = NULL  # Auto-detect from data
```

---

## Priority 4: Low (Documentation/Polish)

These improve user experience but don't affect functionality.

### 4.1 Update README.md

**File**: readme.md -> README.md
**Complexity**: M
**Why**: Missing key sections

- [ ] Rename to README.md (capital)
- [ ] Add installation instructions
- [ ] Add quick start example
- [ ] Update badges to GitHub Actions
- [ ] Add plot gallery with images
- [ ] Add license section

### 4.2 Configure pkgdown

**Files**: _pkgdown.yml, .github/workflows/pkgdown.yaml
**Complexity**: M
**Why**: No documentation site

- [ ] Create `_pkgdown.yml` with reference organization
- [ ] Configure articles
- [ ] Set up GitHub Pages deployment

### 4.3 Fix Vignettes

**Files**: vignettes/*.Rmd
**Complexity**: M
**Why**: May not build correctly

- [ ] Verify all vignettes build: `devtools::build_vignettes()`
- [ ] Fix any build errors
- [ ] Update code examples to modern syntax
- [ ] Remove or complete stub vignettes (missing_stu.Rmd)

### 4.4 Add Working @examples

**Files**: R/*.R
**Complexity**: M
**Why**: Most examples use `\dontrun{}`

Priority functions:
- [ ] becca_plot()
- [ ] galloping_elephants()
- [ ] haid_plot()
- [ ] quealy_subgroups()
- [ ] goalbar()
- [ ] mapvizieR()

### 4.5 Update NEWS.md

**File**: NEWS.md
**Complexity**: S
**Why**: Not updated since ~2017

Add entry for modernization update documenting:
- Breaking changes
- New features
- Bug fixes
- Deprecations

### 4.6 Add .Rbuildignore Entries

**File**: .Rbuildignore
**Complexity**: S
**Why**: Missing entries for new files

Add:
```
^\.github$
^_pkgdown\.yml$
^pkgdown$
^docs$
^analysis$
^\.codecov\.yml$
```

### 4.7 Update .lintr

**File**: .lintr
**Complexity**: S
**Why**: Use modern lintr syntax

```r
linters: linters_with_defaults(
  line_length_linter(120),
  object_name_linter(styles = c("snake_case", "camelCase"))
)
```

---

## Implementation Order

### Phase A: Make Package Installable (Day 1 Morning)

1. [x] Create modernization branch
2. [ ] Task 1.1: Remove ensurer dependency
3. [ ] Task 1.4: Update DESCRIPTION
4. [ ] Task 1.2: Delete wercker.yml
5. [ ] Run `devtools::check()` - fix any errors

### Phase B: Fix Deprecations (Day 1 Afternoon)

6. [ ] Task 2.1: Fix ggplot2 deprecations
7. [ ] Task 2.2: Fix dplyr scoped verbs
8. [ ] Task 2.3: Remove reshape2 (if used)
9. [ ] Task 2.4: Update NAMESPACE imports

### Phase C: CI/CD Setup (Day 1 Evening)

10. [ ] Task 1.3: Create GitHub Actions workflows
11. [ ] Task 4.6: Update .Rbuildignore
12. [ ] Push and verify CI passes

### Phase D: Testing (Day 2 Morning)

13. [ ] Task 3.1: Add testthat 3e
14. [ ] Task 3.2: Add visual regression tests
15. [ ] Run all tests, fix failures

### Phase E: Code Quality (Day 2 Afternoon)

16. [ ] Task 3.3: Add input validation
17. [ ] Task 3.4: Create centralized theme
18. [ ] Task 3.5: Split util.R (optional)
19. [ ] Task 3.6: Fix hardcoded years

### Phase F: Documentation (Day 2 Evening)

20. [ ] Task 4.1: Update README.md
21. [ ] Task 4.2: Configure pkgdown
22. [ ] Task 4.3: Fix vignettes
23. [ ] Task 4.4: Add working @examples
24. [ ] Task 4.5: Update NEWS.md
25. [ ] Task 4.7: Update .lintr

### Phase G: Validation (Day 3)

26. [ ] Run `devtools::check()` - must pass
27. [ ] Run `devtools::test()` - all tests pass
28. [ ] Run `lintr::lint_package()`
29. [ ] Build pkgdown site: `pkgdown::build_site()`
30. [ ] Install and test manually

---

## Success Metrics

- [ ] `R CMD check` passes with 0 errors, 0 warnings
- [ ] All tests pass
- [ ] No deprecation warnings when running plots
- [ ] pkgdown site builds and deploys
- [ ] GitHub Actions CI is green
- [ ] Package installs cleanly
- [ ] Core visualizations work correctly

---

## Files Modified Summary

### Deleted
- wercker.yml

### Created
- .github/workflows/R-CMD-check.yaml
- .github/workflows/test-coverage.yaml
- .github/workflows/pkgdown.yaml
- .github/workflows/lint.yaml
- _pkgdown.yml
- .codecov.yml
- R/theme_mapvizier.R
- tests/testthat/test-visual-*.R
- analysis/*.md (documentation)

### Modified
- DESCRIPTION
- NAMESPACE
- .Rbuildignore
- .lintr
- NEWS.md
- README.md
- R/mapvizieR_object.R
- R/util.R
- R/becca_plot.R
- R/haid_plot.R
- R/galloping_elephants.R
- R/quealy_subgroups.R
- R/goalbar.R
- R/roster_to_df.R
- R/goals_and_projections.R
- Multiple other R files with deprecation fixes
