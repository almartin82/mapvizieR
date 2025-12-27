# quealy_permutation_stats

calculates group stats for all the permutations of a subroup. used to be
internal to quealy_subgroups, has been extracted.

## Usage

``` r
quealy_permutation_stats(df, subgroup, norms = 2015)
```

## Arguments

- df:

  a growth data frame

- subgroup:

  the subgroup to group and calculate summary stats for

- norms:

  school growth norms to use. 2012 or 2015.

## Value

a data frame
