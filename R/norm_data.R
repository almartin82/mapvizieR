#' student_status_norms_2011 NWEA student norm data (2011 study)
#'
#' Norm data published by NWEA: 
#' Given a subject, grade level, season and RIT, gives a percentile rank
#' 
#' @format
#' \describe{
#' \item{measurementscale}{measurementscale}
#' \item{fallwinterspring}{fallwinterspring}
#' \item{grade}{grade}
#' \item{RIT}{RIT}
#' \item{percentile}{percentile}
#' }
#' @source http://support.nwea.org/support/article/rit-scale-norms-study-data-files
"student_status_norms_2011"


#' status_norms_2015 NWEA student and school status (or, attainment) 
#' norms data (2015 study)
#'
#' Norm data published by NWEA: 
#' Given a subject, grade level, season and RIT, gives a percentile rank
#' 
#' @format
#' \describe{
#' \item{measurementscale}{measurementscale}
#' \item{fallwinterspring}{fallwinterspring}
#' \item{grade}{grade}
#' \item{RIT}{RIT}
#' \item{student_percentile}{student_percentile}
#' \item{school_percentile}{school_percentile}
#' }
#' @source http://support.nwea.org/support/article/rit-scale-norms-study-data-files
"status_norms_2015"


#' student_growth_norms_2015 NWEA student growth 
#' norms data (2015 study)
#'
#' Norm data published by NWEA: 
#' Given a subject, grade level, pre-test and post-test seasons and start RIT, expected growth 
#' and variance statistics.
#' 
#' @format
#' \describe{
#' \item{Subject}{Measurement Scale, Possible Values: 1 = Mathematics, 2 = Reading, 
#' 3 = Language Usage, 4 = General science}
#' \item{Grade}{The RIT score of the test in the first term of the comparison period. 
#' Scores are now represented with as many as 14‐decimal places, which is clearly overboard.}
#' \item{T41}{Growth projection for comparison period fall of this grade to winter of this grade. 
#' Negative numbers likely due to extrapolation.}
#' \item{T42}{Growth projection for comparison period fall of this grade to spring of this grade. 
#' Negative numbers likely due to extrapolation.}
#' \item{T44}{Growth projection for comparison period fall of this grade to fall of next grade. 
#' Negative numbers likely due to extrapolation.}
#' \item{T22}{Growth projection for comparison period spring of last grade to spring of this grade. 
#' Negative numbers likely due to extrapolation.}
#' \item{T12}{Growth projection for comparison period winter of this grade to spring of this grade. 
#' Negative numbers likely due to extrapolation.}
#' \item{T11}{Growth projection for comparison period winter of last grade to winter of this grade. 
#' Negative numbers likely due to extrapolation.}
#' \item{R41}{Reported growth projection for comparison period fall of this grade to winter of this grade.}
#' \item{R42}{Reported growth projection for comparison period fall of this grade to spring of this grade.}
#' \item{R44}{Reported growth projection for comparison period fall of this grade to fall of next grade.}
#' \item{R22}{Reported growth projection for comparison period spring of last grade to spring of this grade.}
#' \item{R12}{Reported growth projection for comparison period winter of this grade to spring of this grade.}
#' \item{R11}{Reported growth projection for comparison period winter of last grade to winter of this grade}
#' \item{S41}{Standard deviation of growth projection for comparison period fall of this grade to winter of this grade.}
#' \item{S42}{Standard deviation growth projection for comparison period fall of this grade to spring of this grade.}
#' \item{S44}{Standard deviation growth projection for comparison period fall of this grade to fall of next grade.}
#' \item{S22}{Standard deviation growth projection for comparison period spring of last grade to spring of this grade.}
#' \item{S12}{Standard deviation growth projection for comparison period winter of this grade to spring of this grade.}
#' \item{S11}{Standard deviation growth projection for comparison period winter of last grade to winter of this grade.}
#' \item{MeasurementScale}{Measurement scale in plain English.}
#' }
#' @source http://support.nwea.org/support/article/rit-scale-norms-study-data-files
"status_norms_2015"





#' student_status_norms_2011_dense_extended 2011 norm data densified and extended
#'
#' Builds on student_status_norms_2011. Two data processing steps have been performed:
#' 1) densification by percentile.  For many grade levels, one step on the RIT scale 
#' equates to more than one percentile point.  For instnace, moving from RIT 212 to 213
#' might be a jump from the 51st to 54th percentile.  This dataframe 'densifies' the 
#' scale so that entries exist for the 52nd and 53rd percentile (mapping back to RIT 212).
#' 2) extending norms into HS.  The normative study doesn't cover all grades and subjects - 
#' in 2011, comparatively few HS students took MAP.  Rather than return nothing at all
#' for, say, 12th grade Reading, this data frame extends the norms from the previous grade
#' where data exists.  This is an imperfect approximation, to be sure, but is at least 
#' directionally accurate.
#' 
#' @format
#' \describe{
#' \item{measurementscale}{measurementscale}
#' \item{fallwinterspring}{fallwinterspring}
#' \item{grade}{grade}
#' \item{RIT}{RIT}
#' \item{percentile}{percentile}
#' }
#' @source http://support.nwea.org/support/article/rit-scale-norms-study-data-files
"student_status_norms_2011_dense_extended"
