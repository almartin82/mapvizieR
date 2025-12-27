# Create vector of Initials

`abbrev` returns a character vector of each words first capital letters
for each element of `x`.

## Usage

``` r
abbrev(x, exceptions = NULL)
```

## Arguments

- x:

  vector of strings to be abbreviated.

- exceptions:

  list with two names vectors: `old`, a vector abbreviations to be
  replaced and `new`, a vector of replacment values.

## Value

a character vector of `length(x)`.

## Details

This function returns a same-length character vector that abbrevs an
initial character vector, `x`. Abbreviation returns the first capital
letter of any words in each element of `x`. Users may additionally pass
`abbrev` an optional list of exceptions that overides the default
abbreviations. The list of exceptions requires a vector of "old" values
to be replaced by "new" values

## Examples

``` r
x<-c("KIPP Ascend Middle School", "KIPP Ascend Primary School", 
     "KIPP Create College Prep", 
     "KIPP Bloom College Prep" ,
     "KIPP One Academy")

abbrev(x)
#> [1] "KAMS" "KAPS" "KCCP" "KBCP" "KOA" 

altnames<-list(old=c("KAPS", "KBCP", "KOA"), 
                 new=c("KAP", "Bloom", "One"))

abbrev(x, exceptions=altnames)
#> [1] "KAMS"  "KAP"   "KCCP"  "Bloom" "One"  
```
