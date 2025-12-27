# Standardize Kindergarten code to 0 and other grades to integers

`standardize_kinder` returns an integer vector grade levels.

## Usage

``` r
standardize_kinder(x, other_codes = NULL)
```

## Arguments

- x:

  a character, integer, or numeric vector of grade levels

- other_codes:

  a vector of alternative codes for kindergarten to be translated to 0

## Value

an integer vector of `length(x)`.

## Details

This function simply translates kindergarten codes 13 (from client-based
MAP), "K", or a user specified `kinder_code` from an input vector `x` to
0 and recasts the input vector to an integer vector.

## Examples

``` r
# Create vector of grades 1 through 13, where 13 = kinder
x <- sample(x=1:13, 100,replace = TRUE)
standardize_kinder(x)
#>   [1]  8 12  9  2  4  5  8  0  0  5  0 12  8  4 12  6  0  4  8  6  6 11 11  9  7
#>  [26]  7 12  2  4  4  7  9  4  5  7 10  2 11  5  2  8  5 11  4  3  4  1  7  1  5
#>  [51]  6 10  0  7  3  8  7  0  2  1  1  9 10 11  0  3 11 10  4  8  8  5  0  0  0
#>  [76]  7 11  1  2  9  8  3  2 11  4  5  3  1  1  3  9  4  3  1  1  8  4  6  0 10

# change 13 to "K"
x2 <- ifelse(x==13, "K", x)
standardize_kinder(x2)
#>   [1]  8 12  9  2  4  5  8  0  0  5  0 12  8  4 12  6  0  4  8  6  6 11 11  9  7
#>  [26]  7 12  2  4  4  7  9  4  5  7 10  2 11  5  2  8  5 11  4  3  4  1  7  1  5
#>  [51]  6 10  0  7  3  8  7  0  2  1  1  9 10 11  0  3 11 10  4  8  8  5  0  0  0
#>  [76]  7 11  1  2  9  8  3  2 11  4  5  3  1  1  3  9  4  3  1  1  8  4  6  0 10

# change "K" to "Kinder"
x3 <- ifelse(x=="K", "Kinder", x)
standardize_kinder(x2, other_codes="Kinder")
#>   [1]  8 12  9  2  4  5  8  0  0  5  0 12  8  4 12  6  0  4  8  6  6 11 11  9  7
#>  [26]  7 12  2  4  4  7  9  4  5  7 10  2 11  5  2  8  5 11  4  3  4  1  7  1  5
#>  [51]  6 10  0  7  3  8  7  0  2  1  1  9 10 11  0  3 11 10  4  8  8  5  0  0  0
#>  [76]  7 11  1  2  9  8  3  2 11  4  5  3  1  1  3  9  4  3  1  1  8  4  6  0 10
```
