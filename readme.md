# mapvizieR

mapvizieR is an R package that generates visualizations and reports for NWEA MAP data.

## development guidelines

- write tests & vignettes off of the sample CDF in `data/CombinedAssessmentRsults.csv`

- did you how it said 'write tests' up there?  write tests!

- separate data processing functions from visualization functions

- use ggplot themes, where possible, to handle formatting stuff (font size, transparency, etc) on plots
