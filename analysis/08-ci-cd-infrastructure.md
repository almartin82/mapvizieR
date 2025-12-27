# CI/CD Infrastructure Analysis - mapvizieR

## Executive Summary

The package has **no working CI/CD infrastructure**. The existing `wercker.yml` is deprecated and non-functional. Immediate migration to GitHub Actions is required for automated testing, code coverage, and documentation deployment.

## 1. Current State: wercker.yml (DEPRECATED)

### Existing Configuration

```yaml
box: rocker/hadleyverse

no-response-timeout: 60

build:
    steps:
        - jimhester/r-dependencies
        - jimhester/r-check
        - jimhester/r-coverage
```

### Issues

1. **Wercker is deprecated/defunct** - Service no longer exists
2. **rocker/hadleyverse is outdated** - Replaced by `rocker/verse`, `rocker/tidyverse`
3. **jimhester steps are deprecated** - No longer maintained
4. **No builds running** - CI is completely non-functional

### Required Action

**Delete `wercker.yml`** - It provides no value and is confusing.

## 2. GitHub Actions Migration

### Required Workflows

1. **R-CMD-check** - Standard package checks
2. **test-coverage** - Code coverage reporting
3. **pkgdown** - Documentation site deployment
4. **lint** - Code style checking

### Recommended Directory Structure

```
.github/
├── workflows/
│   ├── R-CMD-check.yaml
│   ├── test-coverage.yaml
│   ├── pkgdown.yaml
│   └── lint.yaml
├── ISSUE_TEMPLATE/
│   ├── bug_report.md
│   └── feature_request.md
└── PULL_REQUEST_TEMPLATE.md
```

## 3. R-CMD-check Workflow

### Recommended Configuration

```yaml
# .github/workflows/R-CMD-check.yaml
name: R-CMD-check

on:
  push:
    branches: [main, master]
  pull_request:
    branches: [main, master]

jobs:
  R-CMD-check:
    runs-on: ${{ matrix.config.os }}

    name: ${{ matrix.config.os }} (${{ matrix.config.r }})

    strategy:
      fail-fast: false
      matrix:
        config:
          - {os: macos-latest,   r: 'release'}
          - {os: windows-latest, r: 'release'}
          - {os: ubuntu-latest,  r: 'devel', http-user-agent: 'release'}
          - {os: ubuntu-latest,  r: 'release'}
          - {os: ubuntu-latest,  r: 'oldrel-1'}

    env:
      GITHUB_PAT: ${{ secrets.GITHUB_TOKEN }}
      R_KEEP_PKG_SOURCE: yes

    steps:
      - uses: actions/checkout@v4

      - uses: r-lib/actions/setup-pandoc@v2

      - uses: r-lib/actions/setup-r@v2
        with:
          r-version: ${{ matrix.config.r }}
          http-user-agent: ${{ matrix.config.http-user-agent }}
          use-public-rspm: true

      - uses: r-lib/actions/setup-r-dependencies@v2
        with:
          extra-packages: any::rcmdcheck
          needs: check

      - uses: r-lib/actions/check-r-package@v2
        with:
          upload-snapshots: true
```

### Key Features

- Tests on multiple OS (macOS, Windows, Ubuntu)
- Tests on multiple R versions (devel, release, oldrel)
- Uses r-lib/actions for standardized R package workflows
- Uploads test snapshots for debugging

## 4. Test Coverage Workflow

### Recommended Configuration

```yaml
# .github/workflows/test-coverage.yaml
name: test-coverage

on:
  push:
    branches: [main, master]
  pull_request:
    branches: [main, master]

jobs:
  test-coverage:
    runs-on: ubuntu-latest

    env:
      GITHUB_PAT: ${{ secrets.GITHUB_TOKEN }}

    steps:
      - uses: actions/checkout@v4

      - uses: r-lib/actions/setup-r@v2
        with:
          use-public-rspm: true

      - uses: r-lib/actions/setup-r-dependencies@v2
        with:
          extra-packages: any::covr
          needs: coverage

      - name: Test coverage
        run: |
          covr::codecov(
            quiet = FALSE,
            clean = FALSE,
            install_path = file.path(normalizePath(Sys.getenv("RUNNER_TEMP"), winslash = "/"), "package")
          )
        shell: Rscript {0}

      - name: Show testthat output
        if: always()
        run: |
          find ${{ runner.temp }}/package -name 'testthat.Rout*' -exec cat '{}' \; || true
        shell: bash

      - name: Upload test results
        if: failure()
        uses: actions/upload-artifact@v4
        with:
          name: coverage-test-failures
          path: ${{ runner.temp }}/package
```

### Codecov Integration

1. Repository should already have codecov configured (badge in README)
2. Verify codecov token in repository secrets (if private repo)
3. Create `.codecov.yml` for configuration:

```yaml
# .codecov.yml
coverage:
  status:
    project:
      default:
        target: 70%
        threshold: 5%
    patch:
      default:
        target: 60%

comment:
  layout: "reach, diff, flags, files"
  behavior: default
  require_changes: false
```

## 5. pkgdown Deployment Workflow

### Recommended Configuration

```yaml
# .github/workflows/pkgdown.yaml
name: pkgdown

on:
  push:
    branches: [main, master]
  release:
    types: [published]
  workflow_dispatch:

jobs:
  pkgdown:
    runs-on: ubuntu-latest

    # Only restrict concurrency for non-PR jobs
    concurrency:
      group: pkgdown-${{ github.event_name != 'pull_request' || github.run_id }}

    env:
      GITHUB_PAT: ${{ secrets.GITHUB_TOKEN }}

    permissions:
      contents: write

    steps:
      - uses: actions/checkout@v4

      - uses: r-lib/actions/setup-pandoc@v2

      - uses: r-lib/actions/setup-r@v2
        with:
          use-public-rspm: true

      - uses: r-lib/actions/setup-r-dependencies@v2
        with:
          extra-packages: any::pkgdown, local::.
          needs: website

      - name: Build site
        run: pkgdown::build_site_github_pages(new_process = FALSE, install = FALSE)
        shell: Rscript {0}

      - name: Deploy to GitHub pages
        if: github.event_name != 'pull_request'
        uses: JamesIves/github-pages-deploy-action@v4.5.0
        with:
          clean: false
          branch: gh-pages
          folder: docs
```

### GitHub Pages Setup

1. Go to repository Settings > Pages
2. Set source to "Deploy from a branch"
3. Select `gh-pages` branch, `/ (root)` folder
4. Site will be available at: https://almartin82.github.io/mapvizieR/

## 6. Linting Workflow

### Recommended Configuration

```yaml
# .github/workflows/lint.yaml
name: lint

on:
  push:
    branches: [main, master]
  pull_request:
    branches: [main, master]

jobs:
  lint:
    runs-on: ubuntu-latest

    env:
      GITHUB_PAT: ${{ secrets.GITHUB_TOKEN }}

    steps:
      - uses: actions/checkout@v4

      - uses: r-lib/actions/setup-r@v2
        with:
          use-public-rspm: true

      - uses: r-lib/actions/setup-r-dependencies@v2
        with:
          extra-packages: any::lintr, local::.
          needs: lint

      - name: Lint
        run: lintr::lint_package()
        shell: Rscript {0}
        env:
          LINTR_ERROR_ON_LINT: true
```

### Update .lintr Configuration

Current `.lintr`:
```r
linters: with_defaults(line_length_linter(120))
```

Recommended update:
```r
linters: linters_with_defaults(
  line_length_linter(120),
  object_name_linter(styles = c("snake_case", "camelCase")),
  commented_code_linter = NULL
)
exclusions: list(
  "data-raw" = list(linters = list())
)
```

## 7. Branch Protection Recommendations

### Settings for `master` Branch

1. **Require pull request reviews**:
   - Required approving reviews: 1
   - Dismiss stale pull request approvals

2. **Require status checks**:
   - R-CMD-check (ubuntu-latest, release)
   - Require branches to be up to date

3. **Include administrators**: Optional but recommended

### Configuration

Go to Settings > Branches > Add rule:
- Branch name pattern: `master`
- Check: "Require a pull request before merging"
- Check: "Require status checks to pass before merging"
- Select: "R-CMD-check / R-CMD-check (ubuntu-latest, release)"

## 8. Release Automation

### GitHub Release Workflow (Optional)

```yaml
# .github/workflows/release.yaml
name: Release

on:
  push:
    tags:
      - 'v*'

jobs:
  release:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Create Release
        uses: softprops/action-gh-release@v1
        with:
          generate_release_notes: true
```

### Release Process

1. Update version in DESCRIPTION
2. Update NEWS.md
3. Commit changes
4. Tag release: `git tag v0.4.0`
5. Push tag: `git push origin v0.4.0`
6. GitHub Actions creates release automatically

## 9. Visual Regression Testing in CI

### vdiffr Integration

Add to R-CMD-check workflow:
```yaml
      - uses: r-lib/actions/setup-r-dependencies@v2
        with:
          extra-packages: |
            any::rcmdcheck
            any::vdiffr
          needs: check
```

### Handling Snapshot Failures

The workflow already includes:
```yaml
      - uses: r-lib/actions/check-r-package@v2
        with:
          upload-snapshots: true
```

This uploads snapshots when tests fail, allowing review.

## 10. .Rbuildignore Updates

### Current .Rbuildignore

```
^mapvizieR\.Rproj$
^\.Rproj\.user$
^data-raw$
^wercker\.yml$
```

### Recommended Additions

```
^mapvizieR\.Rproj$
^\.Rproj\.user$
^data-raw$
^wercker\.yml$
^\.github$
^_pkgdown\.yml$
^pkgdown$
^docs$
^analysis$
^\.lintr$
^\.codecov\.yml$
^LICENSE\.md$
^README\.Rmd$
^cran-comments\.md$
^CRAN-SUBMISSION$
^\.vscode$
```

## Implementation Checklist

### Step 1: Remove Old CI

```bash
rm wercker.yml
```

### Step 2: Create GitHub Actions Directory

```bash
mkdir -p .github/workflows
```

### Step 3: Create Workflow Files

Create the four workflow files:
1. `.github/workflows/R-CMD-check.yaml`
2. `.github/workflows/test-coverage.yaml`
3. `.github/workflows/pkgdown.yaml`
4. `.github/workflows/lint.yaml`

### Step 4: Update Supporting Files

1. Update `.Rbuildignore`
2. Update `.lintr`
3. Create `.codecov.yml`
4. Create `_pkgdown.yml`

### Step 5: Configure Repository

1. Enable GitHub Pages
2. Configure branch protection
3. Verify codecov integration

### Step 6: Verify Workflows

1. Push changes to branch
2. Open PR to master
3. Verify all checks pass
4. Merge and verify pkgdown deploys

## Summary: CI/CD Status

| Component | Current State | Target State | Priority |
|-----------|--------------|--------------|----------|
| R-CMD-check | None | GitHub Actions | Critical |
| Test coverage | Broken | Working codecov | High |
| Documentation | None | pkgdown on GitHub Pages | High |
| Linting | Manual | Automated in CI | Medium |
| Releases | Manual | Tag-triggered | Low |
| Branch protection | None | Configured | Medium |

## Immediate Actions

1. **Delete wercker.yml**
2. **Create .github/workflows/ directory**
3. **Add R-CMD-check.yaml** (most important)
4. **Add test-coverage.yaml**
5. **Add pkgdown.yaml**
6. **Push and verify CI works**
