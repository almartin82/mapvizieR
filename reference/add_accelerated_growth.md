# Add an accelerated growth object, including projections and simulations, to a mapvizieR object

`add_accelerated_growth` is a constructor function that adds a "goals"
object (a list with a `goals` data frame, a `join_by_fields` character
vector, and `slot_name` single element character vector) to a
[`mapvizieR`](https://almartin82.github.io/mapvizieR/reference/mapvizieR.md)
object. The goals object is added to a `goals` slot in the `mapvizieR`
object. The goals themselves, as well as any projections or simulations,
are created by a "goals function" (see
[`goal_kipp_tiered`](https://almartin82.github.io/mapvizieR/reference/goal_kipp_tiered.md)
for an example) that is passed as the `goal_function argument`;
arguments to the `goal_function` are passed via the `goal_function_args`
argument. Note well that the `goal_function` must (i) return a list with
three elements (the goals data frame, the join_by_fields character
vector, and the slot_name) and (ii) the goals data frame must have at
least fields named `accel_growth` and `met_accel_growth`. If the
`updated_growth_df` is TRUE then the goals data frame is `inner_join`ed
with the `growth_df` using the `join_by_fields`, accelerated growth
columns are added or updated, and any duplicate columns from the join
are cleaned up (original columns from the `growth_df` are maintened).
Obviouslly, the goals function should return a one to one match on any
first iterations.

## Usage

``` r
add_accelerated_growth(
  mapvizier_object,
  goal_function = goal_kipp_tiered,
  goal_function_args = list(iterations = 1),
  update_growth_df = FALSE
)
```

## Arguments

- mapvizier_object:

  a
  [`mapvizieR`](https://almartin82.github.io/mapvizieR/reference/mapvizieR.md)
  object.

- goal_function:

  a function that returns a list containing a a data frame named
  `goals`, a character vector of columns used to join accelerated goals
  to `growth_df`, and `slot_name` single element character vector used
  to name the slot in the `goals` element of a `mapvizieR` object.

- goal_function_args:

  arguments passed to `goal_function`

- update_growth_df:

  if `TRUE` accelerated growth and met accelerated growth columns are
  added/updated in the `growth_df` of a `mapvizieR` object

## Value

a
[`mapvizieR`](https://almartin82.github.io/mapvizieR/reference/mapvizieR.md)
object.

## Examples

``` r
if (FALSE) { # \dontrun{
data(ex_CombinedAssessmentResults)
data(ex_CombinedStudentsBySchool)

cdf_mv <- mapvizieR(
 ex_CombinedAssessmentResults, 
 ex_CombinedStudentsBySchool
)
                    
new_mv <- add_accelerated_growth(
 cdf_mv,
 goal_function = goal_kipp_tiered, 
 goal_function_args = list(iterations=1),
 update_growth_df = FALSE
)
str(new_mv)                                
} # }
```
