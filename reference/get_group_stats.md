# Calculate quartiles stats for `haid_plot`

`get_group_stats` calculates counts and percentages used in `haid_plot`

## Usage

``` r
get_group_stats(df, grp, RIT, dummy_y)
```

## Arguments

- df:

  a data frames with individual RIT scores and grouping variable

- grp:

  the variable to group by

- RIT:

  the column in the data frame with RIT scores

- dummy_y:

  column used to establish data placement on `haid_plot`

## Value

A data frame with aggregate values grouped by grp for count of students,
y-axis placement, group average RIT, percent of students in group
(relative to total students), and the total count of students.
