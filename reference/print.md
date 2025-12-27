# print method for `mapvizier` class

prints to console

## Usage

``` r
# S3 method for class 'mapvizieR'
print(x, ...)
```

## Arguments

- x:

  a `mapvizier` object

- ...:

  additional arguments

## Value

some details about the object to the console.

## Details

Prints a summary of the a `mapvizier` object.

## Examples

``` r
if (FALSE) { # \dontrun{
data(ex_CombinedAssessmentResults)
data(ex_CombinedStudentsBySchool)

cdf_mv <- mapvizieR(ex_CombinedAssessmentResults, 
                    ex_CombinedStudentsBySchool)
                    
cdf_mv
} # }
```
