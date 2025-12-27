# Deploy Command

Deploy the mapvizieR package after running all checks.

## Steps

Execute the following steps in order. Stop immediately if any step fails.

### 1. Security Review

Search the codebase for potential security issues:
- Check for hardcoded credentials or API keys
- Look for unsafe file operations
- Check for command injection vulnerabilities
- Review any external URL references
- Check for unsafe deserialization

Report any findings before proceeding.

### 2. Run Tests

Run the full test suite:
```r
devtools::test()
```

All tests must pass. Report test results.

### 3. Run Linter

Run lintr on the R code:
```r
lintr::lint_package()
```

Report any linting issues. Critical issues should block deployment.

### 4. Build and Check

Run R CMD check:
```r
devtools::check(args = c("--no-manual", "--no-vignettes"))
```

The check must pass with no errors. Warnings and notes are acceptable.

### 5. Deploy

If all checks pass:

1. Stage all changes: `git add -A`
2. Commit with message describing changes
3. Push to remote: `git push`

The push will trigger the pkgdown workflow to rebuild the documentation site.

### 6. Sync Analysis Repository (if changes exist)

If there are changes in the `analysis/` directory:

1. Navigate to analysis: `cd analysis/`
2. Check for changes: `git status`
3. If changes exist:
   - Stage all: `git add -A`
   - Commit with timestamp: `git commit -m "Sync analysis docs - $(date +%Y-%m-%d)"`
   - Push: `git push origin main`
4. Return to root: `cd ..`

Note: The analysis repo is private. Deployment continues even if this step fails.

## Failure Handling

If any step fails:
- Report the specific failure
- Do NOT proceed to deployment
- Suggest fixes for the issues found
