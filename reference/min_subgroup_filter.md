# min_subgroup_filter

given a data frame and some arbitrary subgroup, return only the rows
that are members of subgroups that make up at least n

## Usage

``` r
min_subgroup_filter(df, subgroup_name, small_n_cutoff = -1)
```

## Arguments

- df:

  some data frame

- subgroup_name:

  of a column of the data frame

- small_n_cutoff:

  anything below this percent will get filtered out. default is -1, eg
  off
