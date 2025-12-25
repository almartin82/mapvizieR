#!/usr/bin/env Rscript

# Visual Tests Runner
# This script demonstrates how to run visual regression tests for mapvizieR

# Check if required packages are installed
required_pkgs <- c("testthat", "vdiffr", "ggplot2")
missing_pkgs <- required_pkgs[!sapply(required_pkgs, requireNamespace, quietly = TRUE)]

if (length(missing_pkgs) > 0) {
  message("Installing missing packages: ", paste(missing_pkgs, collapse = ", "))
  install.packages(missing_pkgs)
}

# Load testthat
library(testthat)

# Set working directory to package root if needed
if (basename(getwd()) == "tests") {
  setwd("..")
}

message("\n=== Running Visual Regression Tests ===\n")
message("These tests will create SVG snapshots of plots if they don't exist,")
message("or compare against existing snapshots if they do.\n")

# Run just the visual tests
result <- test_file(
  "tests/testthat/test-visual-plots.R",
  reporter = "progress"
)

# Print summary
message("\n=== Test Summary ===")
message("Total tests: ", length(result))
message("Passed: ", sum(sapply(result, function(x) inherits(x, "expectation_success"))))
message("Failed: ", sum(sapply(result, function(x) inherits(x, "expectation_failure"))))
message("Skipped: ", sum(sapply(result, function(x) inherits(x, "expectation_skip"))))

# Check for snapshot changes
snapshot_dir <- "tests/testthat/_snaps/visual-plots"
if (dir.exists(snapshot_dir)) {
  snapshots <- list.files(snapshot_dir, pattern = "\\.svg$")
  message("\nSnapshot files: ", length(snapshots))
  if (length(snapshots) > 0) {
    message("Located at: ", snapshot_dir)
  }
} else {
  message("\nNo snapshots directory found yet.")
  message("Snapshots will be created when you first accept the test results.")
}

message("\n=== Next Steps ===")
message("1. If snapshots were newly created, review them visually")
message("2. Accept snapshots with: testthat::snapshot_accept()")
message("3. Or use interactive review: vdiffr::manage_cases()")
message("\nSee visual-tests-guide.md for more details.\n")
