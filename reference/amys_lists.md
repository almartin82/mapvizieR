# Students' names stacked by category, or a more informative bar graph.

`amys_lists` implements bar charts that created by ranking and stacking
student names for each growth status bin (i.e., negative growth, not
typical, typical, and college ready growth). The name is from KIPP
Chicago CAO Amy Pouba, who came up with the idea. This visualizaiton is
nice in that it provides a quick overview of the distribution of growth
statuses while simultaneously providing student-level information
(student name, end RIT score, and gorwth status).

## Usage

``` r
amys_lists(
  mapvizieR_obj,
  studentids,
  measurementscale,
  start_fws,
  start_academic_year,
  end_fws,
  end_academic_year
)
```

## Arguments

- mapvizieR_obj:

  mapvizieR object

- studentids:

  target students

- measurementscale:

  target subject

- start_fws:

  starting season

- start_academic_year:

  starting academic year

- end_fws:

  ending season

- end_academic_year:

  ending academic year
