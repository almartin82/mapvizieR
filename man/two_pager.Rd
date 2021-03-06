% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/two_pager.R
\name{two_pager}
\alias{two_pager}
\title{MAP two-pager}
\usage{
two_pager(mapvizieR_obj, studentids, measurementscale, start_fws,
  start_academic_year, end_fws, end_academic_year, detail_academic_year,
  national_data_frame = NA, title_text = "",
  entry_grade_seasons = c(-0.8, 4.2), ...)
}
\arguments{
\item{mapvizieR_obj}{mapvizieR object}

\item{studentids}{target students}

\item{measurementscale}{target subject}

\item{start_fws}{starting season}

\item{start_academic_year}{starting academic year}

\item{end_fws}{ending season}

\item{end_academic_year}{ending academic year}

\item{detail_academic_year}{don't mask any data for this academic year}

\item{national_data_frame}{for internal KIPP use - a data frame showing % making
typ growth across KIPP}

\item{title_text}{what is this report called?}

\item{entry_grade_seasons}{for becca plot.  default is c(-0.8, 4.2)}

\item{...}{additional arguments}
}
\value{
a list of grid graphics objects
}
\description{
KNJ style 'two pager' report that shows the progress of a grade 
or cohort
}
