# student_growth_norms_2011 NWEA student growth norms data (2011 study)

Norm data published by NWEA: Given a subject, grade level, pre-test and
post-test seasons and start RIT, expected growth and variance
statistics.

## Usage

``` r
student_growth_norms_2011
```

## Format

- Subject:

  Measurement Scale, Possible Values: 1 = Mathematics, 2 = Reading, 3 =
  Language Usage, 4 = General science

- StartGrade:

  The RIT score of the test in the first term of the comparison period.
  Scores are now represented with as many as 14-decimal places, which is
  clearly overboard.

- T41:

  Growth projection for comparison period fall of this grade to winter
  of this grade. Negative numbers likely due to extrapolation.

- T42:

  Growth projection for comparison period fall of this grade to spring
  of this grade. Negative numbers likely due to extrapolation

- T44:

  Growth projection for comparison period fall of this grade to fall of
  next grade. Negative numbers likely due to extrapolation

- T22:

  Growth projection for comparison period spring of this grade to spring
  of next grade. Negative numbers likely due to extrapolation

- T12:

  Growth projection for comparison period winter of this grade to spring
  of this grade Negative numbers likely due to extrapolation

- R41:

  Reported growth projection for comparison period fall of this grade to
  winter of this grade

- R42:

  Reported growth projection for comparison period fall of this grade to
  spring of this grade

- R44:

  Reported growth projection for comparison period fall of this grade to
  fall of next grade

- R22:

  Reported growth projection for comparison period spring of last grade
  to spring of this grade

- R12:

  Reported growth projection for comparison period winter of this grade
  to spring of this grade

- S41:

  Standard deviation of growth projection for comparison period fall of
  this grade to winter of this grade

- S42:

  Standard deviation growth projection for comparison period fall of
  this grade to spring of this grade

- S44:

  Standard deviation growth projection for comparison period fall of
  this grade to fall of next grade

- S22:

  Standard deviation growth projection for comparison period spring of
  last grade to spring of this grade

- S12:

  Standard deviation growth projection for comparison period winter of
  this grade to spring of this grade

- MeasurementScale:

  Measurement scale in plain English

- norms_year:

  year norms were published, in this case 2011

## Source

http://support.nwea.org/support/article/rit-scale-norms-study-data-files
