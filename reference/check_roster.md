# check_roster

`check_roster` a wrapper around a bunch of individual tests that see if
a roster data frame conforms to mapvizieR expectations

## Usage

``` r
check_roster(roster)
```

## Arguments

- roster:

  a roster file, generated either by prep_roster, or via processing done
  in your data warehouse

## Value

a named list. `$boolean` has true false result; `descriptive` has a more
descriptive string describing what happened.
