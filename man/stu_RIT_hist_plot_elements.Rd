% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/college_plots.R
\name{stu_RIT_hist_plot_elements}
\alias{stu_RIT_hist_plot_elements}
\title{helper function to calculate plot elements per-student for college plots}
\usage{
stu_RIT_hist_plot_elements(stu_rit_history, decode_ho = TRUE)
}
\arguments{
\item{stu_rit_history}{data frame (with cdf headers) with one student}

\item{decode_ho}{holdovers create all kinds of funkiness.  decode_ho will
find apparent holdover events, and only return the student's second bite
at that grade/season apple.}
}
\value{
a list of calculations
}
\description{
helper function to calculate plot elements per-student for college plots
}
