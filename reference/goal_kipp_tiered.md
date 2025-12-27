# Create KIPP Tiered accelerated growth goals

`goal_kipp_tiered` is a "goal function": it creates a list with three
elements: a `goals` data frame (including fields `accel_growth` and
`met_accel_growth` used in the `growth_df` of a
[`mapvizieR`](https://almartin82.github.io/mapvizieR/reference/mapvizieR.md)
object.

## Usage

``` r
goal_kipp_tiered(mapvizier_object, iterations = 1)
```

## Arguments

- mapvizier_object:

  a
  [`mapvizieR`](https://almartin82.github.io/mapvizieR/reference/mapvizieR.md)
  object.

- iterations:

  the number of iterations out from any student test event you wish to
  continue projecting student growth. This features is not yet
  implemented, so it only projects growth one iteration.

## Examples

``` r
if (FALSE) { # \dontrun{
data(ex_CombinedAssessmentResults)
data(ex_CombinedStudentsBySchool)

cdf_mv <- mapvizieR(ex_CombinedAssessmentResults, 
                    ex_CombinedStudentsBySchool)
                    
goals<-goal_kipp_tiered(cdf_mv)                     
} # }
```
