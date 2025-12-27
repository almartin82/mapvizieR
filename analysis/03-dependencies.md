# Dependencies Analysis - mapvizieR

## Executive Summary

The package has several critical dependency issues including an **archived package on CRAN** (ensurer), deprecated function usage across tidyverse packages, and outdated version constraints. Immediate action required for CRAN compliance.

## 1. Current Dependencies (from DESCRIPTION)

### Depends

```r
Depends:
    ggplot2,
    grid,
    gridExtra (>= 0.9.1),
    magrittr,
    purrr,
    R(>= 2.10.0)
```

**Issues:**
- `R(>= 2.10.0)` is far too old (from 2009!) - should be `R(>= 4.1.0)` minimum
- Packages in Depends are loaded into user's search path - many should be Imports

### Imports

```r
Imports:
    assertthat,
    dplyr,
    ensurer,          # CRITICAL: ARCHIVED ON CRAN!
    gtable,
    janitor,
    lubridate,
    readr,
    reshape2,         # Superseded by tidyr
    RGraphics,
    scales,
    stringr,
    tidyr,
    toOrdinal
```

### Suggests

```r
Suggests:
    testthat,
    knitr
```

## 2. Critical: Archived/Deprecated Packages

### CRITICAL: `ensurer` is ARCHIVED on CRAN

The `ensurer` package was **archived on 2023-03-20** and is no longer available.

**Files using ensurer:**

| File | Usage Count | Functions Used |
|------|-------------|----------------|
| `mapvizieR_object.R` | 1 | `ensurer::ensures_that()` |
| `quealy_subgroups.R` | 4 | `ensurer::ensure_that()` |
| `util.R` | 5 | `ensures_that()`, `ensure_that()` |
| `becca_plot.R` | 1 | `ensurer::ensure_that()` |
| `roster_to_df.R` | 2 | `ensurer::ensure_that()` |
| `goals_and_projections.R` | 1 | `ensurer::ensure_that()` |

**Total: ~14 usages across 6+ files**

**Required Action:**
Replace with one of:
1. `rlang::abort()` / `rlang::warn()` - Modern tidyverse approach
2. `cli::cli_abort()` - User-friendly error messages
3. `assertthat::assert_that()` - Already in dependencies

**Replacement Pattern:**
```r
# OLD (ensurer)
df %>% ensurer::ensure_that(
  nrow(.) > 0 ~ "no matching students"
)

# NEW (rlang/cli)
if (nrow(df) == 0) {
  cli::cli_abort("no matching students for the specified subject/terms")
}
```

### `reshape2` is Superseded

The `reshape2` package is superseded by `tidyr`. While still on CRAN, it's in maintenance mode.

**Files using reshape2:** Need to search but likely in data prep functions.

**Required Action:**
- `reshape2::melt()` → `tidyr::pivot_longer()`
- `reshape2::dcast()` → `tidyr::pivot_wider()`

## 3. Outdated Dependencies

### Version Constraints Too Loose

| Package | Current Constraint | Recommended | Reason |
|---------|-------------------|-------------|--------|
| `gridExtra` | `>= 0.9.1` | `>= 2.3` | Major version jump |
| `R` | `>= 2.10.0` | `>= 4.1.0` | Native pipe, modern features |
| `ggplot2` | (none) | `>= 3.4.0` | linewidth change |
| `dplyr` | (none) | `>= 1.1.0` | `.by` argument, modern syntax |
| `tidyr` | (none) | `>= 1.3.0` | Modern pivot functions |

### Packages Missing Version Constraints

All packages in Imports should have minimum versions:
- `dplyr` - needs >= 1.0.0 for `across()`, `pick()`
- `ggplot2` - needs >= 3.4.0 for `linewidth`
- `tidyr` - needs >= 1.0.0 for `pivot_*`

## 4. Opportunities to Reduce Dependencies

### Potentially Removable

| Package | Current Usage | Can Remove? | Reason |
|---------|--------------|-------------|--------|
| `RGraphics` | Unknown | Likely Yes | May be unused |
| `gtable` | Minimal | Maybe | Check usage |
| `reshape2` | melt/dcast | Yes | Replace with tidyr |
| `toOrdinal` | `toOrdinal()` | Maybe | Could implement internally |

### Should Move from Depends to Imports

| Package | Reason to Move |
|---------|----------------|
| `grid` | Not needed in user search path |
| `gridExtra` | Only used internally |
| `purrr` | Only used internally |

### Recommended Depends

```r
Depends:
    R (>= 4.1.0)
```

All others should be Imports.

## 5. Missing Dependencies

### Should Be Explicit

| Package | Currently | Should Be | Usage |
|---------|-----------|-----------|-------|
| `rlang` | Implicit (via dplyr) | Imports | For `abort()`, `.data` |
| `cli` | Not listed | Imports | For better error messages |
| `vdiffr` | Not listed | Suggests | For visual regression tests |
| `rmarkdown` | Not listed | Suggests | For vignettes |

### For New Features

| Package | Purpose |
|---------|---------|
| `ggrepel` | Text label repulsion (issue #301) |
| `viridis` | Accessible color palettes |

## 6. ggplot2 Version Compatibility

### ggplot2 3.4.0 Breaking Changes (2022-11)

The package needs these updates for ggplot2 >= 3.4.0:

| Deprecated | Replacement | Files Affected |
|------------|-------------|----------------|
| `size` for lines | `linewidth` | quealy_subgroups.R, others |
| `aes(size=)` for lines | `aes(linewidth=)` | Multiple |

### ggplot2 3.0.0 Changes (Already handled?)

| Change | Status |
|--------|--------|
| `aes_string()` deprecated | Not found in code (good!) |
| `stat_summary(fun.y=)` deprecated | Need to check |

### Specific Fixes Needed

```r
# quealy_subgroups.R:476
annotate(
  geom = 'rect',
  ...
  size = 1.25  # <- This is for outline, should stay 'size'? Check context
)

# Check all geom_segment, geom_line, geom_path for size -> linewidth
```

## 7. tidyverse Deprecation Updates

### dplyr 1.0+ (2020) - CRITICAL

#### Scoped Verbs (DEPRECATED)

| Deprecated | Replacement | Files |
|------------|-------------|-------|
| `summarize_()` | `summarize()` + `.data` | haid_plot.R:680-686 |
| `group_by_()` | `group_by()` + `.data` | quealy_subgroups.R:357, util.R:648 |
| `select_()` | `select()` + `all_of()` | util.R:644 |
| `mutate_()` | `mutate()` | Check all files |
| `filter_()` | `filter()` | Check all files |

**Example Fix:**
```r
# OLD (deprecated)
dplyr::group_by_(subgroup, quote(measurementscale))

# NEW
dplyr::group_by(.data[[subgroup]], measurementscale)
# or with tidyselect:
dplyr::group_by(across(all_of(subgroup)), measurementscale)
```

#### funs() (DEPRECATED since dplyr 0.8.0)

Search for `funs(` usage - replace with lambda syntax:
```r
# OLD
summarize_at(vars(x, y), funs(mean, sd))

# NEW
summarize(across(c(x, y), list(mean = mean, sd = sd)))
```

### dplyr 1.1+ (2023)

New `.by` argument is available but not required.

### tidyr 1.0+ (2019)

| Deprecated | Replacement | Files |
|------------|-------------|-------|
| `gather()` | `pivot_longer()` | Check all files |
| `spread()` | `pivot_wider()` | Check all files |
| `nest()` old syntax | `nest(.by=)` | Check usage |

## 8. Finding All Deprecated Usages

### Search Commands to Run

```bash
# ensurer usage
grep -r "ensurer::" R/

# Deprecated dplyr scoped verbs
grep -rE "(summarize_|group_by_|select_|mutate_|filter_)\(" R/

# funs() usage
grep -r "funs(" R/

# gather/spread
grep -rE "(gather|spread)\(" R/

# size in ggplot (potential linewidth)
grep -r "size\s*=" R/*.R | grep -i "geom_\(line\|segment\|path\)"
```

### Results Summary

From code review:
- `summarize_()`: Found in haid_plot.R, util.R
- `group_by_()`: Found in quealy_subgroups.R, util.R
- `select_()`: Found in util.R
- `tbl_df()`: Found in util.R (line 46)
- `ensurer::`: Found in ~6 files

## 9. Version Constraint Recommendations

### Updated DESCRIPTION Imports

```r
Depends:
    R (>= 4.1.0)
Imports:
    assertthat (>= 0.2.1),
    cli (>= 3.0.0),
    dplyr (>= 1.1.0),
    ggplot2 (>= 3.4.0),
    grid,
    gridExtra (>= 2.3),
    gtable (>= 0.3.0),
    janitor (>= 2.0.0),
    lubridate (>= 1.8.0),
    magrittr (>= 2.0.0),
    purrr (>= 1.0.0),
    readr (>= 2.0.0),
    rlang (>= 1.0.0),
    scales (>= 1.2.0),
    stringr (>= 1.5.0),
    tidyr (>= 1.3.0)
Suggests:
    knitr (>= 1.40),
    rmarkdown (>= 2.20),
    testthat (>= 3.0.0),
    vdiffr (>= 1.0.0),
    viridis
```

### Removed

- `ensurer` - Archived on CRAN
- `reshape2` - Superseded by tidyr
- `RGraphics` - Verify usage, likely removable
- `toOrdinal` - Verify usage, consider internal implementation

## 10. Migration Path

### Phase 1: Critical (Package Won't Install)

1. **Remove ensurer dependency**
   - Replace all `ensurer::ensure_that()` with `rlang::abort()` pattern
   - Replace all `ensurer::ensures_that()` with custom validation functions
   - Add `cli` and `rlang` to Imports

### Phase 2: High Priority (Deprecation Warnings)

2. **Update dplyr usage**
   - Replace all `*_()` scoped verbs
   - Replace `funs()` with lambda syntax
   - Replace `tbl_df()` with `tibble::as_tibble()`

3. **Update tidyr usage**
   - Replace `gather()` with `pivot_longer()`
   - Replace `spread()` with `pivot_wider()`
   - Remove reshape2 dependency

4. **Update ggplot2 usage**
   - Check all `size` arguments for line-type geoms
   - Replace `panel.margin` with `panel.spacing`

### Phase 3: Modernization

5. **Update version constraints**
   - Set minimum R version to 4.1.0
   - Add minimum versions to all Imports

6. **Dependency cleanup**
   - Move grid, gridExtra, purrr from Depends to Imports
   - Remove unused dependencies
   - Add missing Suggests

## Summary: Priority Actions

### Immediate (Blocking CRAN)
1. Remove `ensurer` - package archived, won't install
2. Add `cli` and `rlang` as replacements

### High Priority
1. Update all deprecated dplyr scoped verbs
2. Remove `reshape2`, use tidyr instead
3. Update ggplot2 deprecations

### Medium Priority
1. Update DESCRIPTION version constraints
2. Clean up Depends vs Imports
3. Add missing Suggests

### Low Priority
1. Consider removing rarely-used dependencies
2. Add new useful dependencies (ggrepel, viridis)
