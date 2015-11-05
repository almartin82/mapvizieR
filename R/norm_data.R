## 
## STATUS NORMS
###

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
#' \item{student_percentile}{student_percentile}
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

##
## STATUS NORMS DENSE
##
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
#' \item{student_percentile}{student_percentile}
#' }
#' @source http://support.nwea.org/support/article/rit-scale-norms-study-data-files
"student_status_norms_2011_dense_extended"


#' student_status_norms_2015_dense_extended 2015 norm data densified and extended
#'
#' Builds on status_norms_2015 for students.  
#' Two data processing steps have been performed:
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
#' \item{student_percentile}{student_percentile}
#' \item{school_percentile}{school_percentile} 
#' }
#' @source http://support.nwea.org/support/article/rit-scale-norms-study-data-files
"student_status_norms_2015_dense_extended"


#' school_status_norms_2015_dense_extended 2015 norm data densified and extended
#'
#' Builds on status_norms_2015 for schools. 
#' Two data processing steps have been performed:
#' 1) densification by percentile.  
#' 2) extending norms into HS.  
#' See student_status_norms_2015_dense_extended for more details
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
"school_status_norms_2015_dense_extended"

##
## STUDENT GROWTH NORMS
##

#' student_growth_norms_2011 NWEA student growth 
#' norms data (2011 study)
#'
#' Norm data published by NWEA: 
#' Given a subject, grade level, pre-test and post-test seasons and start RIT, expected growth 
#' and variance statistics.
#' 
#' @format
#' \describe{
#' \item{Subject}{Measurement Scale, Possible Values: 1 = Mathematics, 2 = Reading, 
#' 3 = Language Usage, 4 = General science}
#' \item{StartGrade}{The RIT score of the test in the first term of the comparison period. Scores are now represented with as many as 14-decimal places, which is clearly overboard.}
#' \item{T41}{Growth projection for comparison period fall of this grade to winter of this grade.
#' Negative numbers likely due to extrapolation.}
#' \item{T42}{Growth projection for comparison period fall of this grade to spring of this grade.
#' Negative numbers likely due to extrapolation}
#' \item{T44}{Growth projection for comparison period fall of this grade to fall of next grade. 
#' Negative numbers likely due to extrapolation}
#' \item{T22}{Growth projection for comparison period spring of this grade to spring of next grade. 
#' Negative numbers likely due to extrapolation}
#' \item{T12}{Growth projection for comparison period winter of this grade to spring of this grade
#' Negative numbers likely due to extrapolation}
#' \item{R41}{Reported growth projection for comparison period fall of this grade to winter of this grade}
#' \item{R42}{Reported growth projection for comparison period fall of this grade to spring of this grade}
#' \item{R44}{Reported growth projection for comparison period fall of this grade to fall of next grade}
#' \item{R22}{Reported growth projection for comparison period spring of last grade to spring of this grade}
#' \item{R12}{Reported growth projection for comparison period winter of this grade to spring of this grade}
#' \item{S41}{Standard deviation of growth projection for comparison period fall of this grade to winter of this grade}
#' \item{S42}{Standard deviation growth projection for comparison period fall of this grade to spring of this grade}
#' \item{S44}{Standard deviation growth projection for comparison period fall of this grade to fall of next grade}
#' \item{S22}{Standard deviation growth projection for comparison period spring of last grade to spring of this grade}
#' \item{S12}{Standard deviation growth projection for comparison period winter of this grade to spring of this grade}
#' \item{MeasurementScale}{Measurement scale in plain English}
#' \item{norms_year}{year norms were published, in this case 2011}
#' }
#' @source http://support.nwea.org/support/article/rit-scale-norms-study-data-files
"student_growth_norms_2011"


#' student_growth_norms_2015 NWEA student growth 
#' norms data (2015 study)
#'
#' Norm data published by NWEA: 
#' Given a subject, grade level, pre-test and post-test seasons and start RIT, expected growth 
#' and variance statistics.
#' 
#' @format
#' \describe{
#' \item{Subject}{Measurement Scale, Possible Values: 1=Mathematics, 2=Reading, 
#' 3=Language Usage, 4=General science}
#' \item{StartGrade}{The RIT score of the first test in the a given period. Scores are now represented with as many as 14decimal places, which is clearly overboard.}
#' \item{T41}{Growth projection for comparison period fall of this grade to winter of this grade.
#' #' Negative numbers likely due to extrapolation.}
#' \item{T42}{Growth projection for comparison period fall of this grade to spring of this grade.
#' Negative numbers likely due to extrapolation.}
#' \item{T44}{Growth projection for comparison period fall of this grade to fall of next grade.
#' #' Negative numbers likely due to extrapolation.}
#' \item{T22}{Growth projection for comparison period spring of this grade to spring of next grade.
#' #' Negative numbers likely due to extrapolation.}
#' \item{T12}{Growth projection for comparison period winter of this grade to spring of this grade.
#' Negative numbers likely due to extrapolation.}
#' \item{T11}{Growth projection for comparison period winter of this grade to winter of next grade.
#'  Negative numbers likely due to extrapolation.}
#' \item{R41}{Reported growth projection for comparison period fall of this grade to winter of this grade}
#' \item{R42}{Reported growth projection for comparison period fall of this grade to spring of this grade}
#' \item{R44}{Reported growth projection for comparison period fall of this grade to fall of next grade}
#' \item{R22}{Reported growth projection for comparison period spring of last grade to spring of this grade}
#' \item{R12}{Reported growth projection for comparison period winter of this grade to spring of this grade}
#' \item{R11}{Reported growth projection for comparison period winter of last grade to winter of this grade}
#' \item{S41}{Standard deviation of growth projection for comparison period fall of this grade to winter of this grade}
#' \item{S42}{Standard deviation growth projection for comparison period fall of this grade to spring of this grade}
#' \item{S44}{Standard deviation growth projection for comparison period fall of this grade to fall of next grade}
#' \item{S22}{Standard deviation growth projection for comparison period spring of last grade to spring of this grade}
#' \item{S12}{Standard deviation growth projection for comparison period winter of this grade to spring of this grade}
#' \item{S11}{Standard deviation growth projection for comparison period winter of last grade to winter of this grade}
#' \item{MeasurementScale}{Measurement scale in plain English}
#' \item{norms_year}{year norms were published, in this case 2015}
#' }
#' @source http://support.nwea.org/support/article/rit-scale-norms-study-data-files
"student_growth_norms_2015"

##
## SCHOOL GROWTH NORMS
##

#' school growth norms 2012 study
#'
#' school / cohort growth norms published by NWEA 
#' these are scraped out of the published PDF tables
#' 
#' @format
#' \describe{
#' \item{grade}{END grade, eg grade 2 spring to spring is grade 1 TO grade 2}
#' \item{measurementscale}{measurementscale}
#' \item{growth_window}{growth_window}
#' \item{start_fallwinterspring}{start_fallwinterspring}
#' \item{end_fallwinterspring}{end_fallwinterspring}
#' \item{typical_cohort_growth}{typical_cohort_growth}
#' \item{sd_of_expectation}{sd_of_expectation}
#' }
#' @source NWEA 2012 school growth study (PDF)
"sch_growth_norms_2012"

##
## ACT LINKING
##

#' ACT linking data frame
#'
#' RIT/ACT equivalencies derived from NWEA ACT linking study
#' 
#' @format
#' \describe{
#' \item{school}{I think this was put into the data to allow for rbinding
#' with a different data set.  Can be ignored.}
#' \item{cohort}{similar to school, can be ignored.}
#' \item{grade}{grade level season for the observation}
#' \item{rit}{RIT equivalency}
#' \item{act}{ACT sub-test equivalency}
#' \item{subject}{Mathematics or Reading}
#' }
#' @source NWEA linking study
"act_df"
