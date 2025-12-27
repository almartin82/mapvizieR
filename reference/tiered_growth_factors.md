# Calculate KIPP Tiered Growth factors

`tiered_growth_factors` takes grade level and quartile data and returns
a vector of KIPP Tiered Growth factors (or multipliers, if you prefer).

## Usage

``` r
tiered_growth_factors(quartile, grade)
```

## Arguments

- quartile:

  a vector of student quartiles

- grade:

  vector of student grade-levels

## Value

a vector of `length(quartile)` of KIPP Tiered Growth factors.

## Details

\# Function takes two vectors—one containing student grade levels and
the other containing student pre-test/season 1 quartiles—and returns a
same-length vector of KIPP Tired Growth factors. These factors are
multiplied by a students typical (i.e., expected) growth to generate
college ready growth.
