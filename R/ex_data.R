#' example ex_CombinedAssessmentResults_pre_2015 file (formerly Comprehensive Data File)
#'
#' MAP assessment results (**pre-2015**), in the format provided by web-based MAP.
#' Data provided from NWEA, by request.  
#' (Note that this is training data, and these students/student records *are not real*!)
#'
#' @format
#' \describe{
#' \item{TermName}{TermName}
#' \item{StudentID}{StudentID}
#' \item{SchoolName}{SchoolName}
#' \item{MeasurementScale}{MeasurementScale}
#' \item{Discipline}{Discipline}
#' \item{GrowthMeasureYN}{GrowthMeasureYN}
#' \item{TestType}{TestType}
#' \item{TestName}{TestName}
#' \item{TestID}{TestID}
#' \item{TestStartDate}{TestStartDate}
#' \item{TestDurationMinutes}{TestDurationMinutes}
#' \item{TestRITScore}{TestRITScore}
#' \item{TestStandardError}{TestStandardError}
#' \item{TestPercentile}{TestPercentile}
#' \item{TypicalFallToFallGrowth}{TypicalFallToFallGrowth}
#' \item{TypicalSpringToSpringGrowth}{TypicalSpringToSpringGrowth}
#' \item{TypicalFallToSpringGrowth}{TypicalFallToSpringGrowth}
#' \item{TypicalFallToWinterGrowth}{TypicalFallToWinterGrowth}
#' \item{RITtoReadingScore}{RITtoReadingScore}
#' \item{RITtoReadingMin}{RITtoReadingMin}
#' \item{RITtoReadingMax}{RITtoReadingMax}
#' \item{Goal1Name}{Goal1Name}
#' \item{Goal1RitScore}{Goal1RitScore}
#' \item{Goal1StdErr}{Goal1StdErr}
#' \item{Goal1Range}{Goal1Range}
#' \item{Goal1Adjective}{Goal1Adjective}
#' \item{Goal2Name}{Goal2Name}
#' \item{Goal2RitScore}{Goal2RitScore}
#' \item{Goal2StdErr}{Goal2StdErr}
#' \item{Goal2Range}{Goal2Range}
#' \item{Goal2Adjective}{Goal2Adjective}
#' \item{Goal3Name}{Goal3Name}
#' \item{Goal3RitScore}{Goal3RitScore}
#' \item{Goal3StdErr}{Goal3StdErr}
#' \item{Goal3Range}{Goal3Range}
#' \item{Goal3Adjective}{Goal3Adjective}
#' \item{Goal4Name}{Goal4Name}
#' \item{Goal4RitScore}{Goal4RitScore}
#' \item{Goal4StdErr}{Goal4StdErr}
#' \item{Goal4Range}{Goal4Range}
#' \item{Goal4Adjective}{Goal4Adjective}
#' \item{Goal5Name}{Goal5Name}
#' \item{Goal5RitScore}{Goal5RitScore}
#' \item{Goal5StdErr}{Goal5StdErr}
#' \item{Goal5Range}{Goal5Range}
#' \item{Goal5Adjective}{Goal5Adjective}
#' \item{Goal6Name}{Goal6Name}
#' \item{Goal6RitScore}{Goal6RitScore}
#' \item{Goal6StdErr}{Goal6StdErr}
#' \item{Goal6Range}{Goal6Range}
#' \item{Goal6Adjective}{Goal6Adjective}
#' \item{Goal7Name}{Goal7Name}
#' \item{Goal7RitScore}{Goal7RitScore}
#' \item{Goal7StdErr}{Goal7StdErr}
#' \item{Goal7Range}{Goal7Range}
#' \item{Goal7Adjective}{Goal7Adjective}
#' \item{Goal8Name}{Goal8Name}
#' \item{Goal8RitScore}{Goal8RitScore}
#' \item{Goal8StdErr}{Goal8StdErr}
#' \item{Goal8Range}{Goal8Range}
#' \item{Goal8Adjective}{Goal8Adjective}
#' \item{TestStartTime}{TestStartTime}
#' \item{PercentCorrect}{PercentCorrect}
#' \item{ProjectedProficiency}{ProjectedProficiency}
#' }
#' @source NWEA MAP partner support team (thanks!)
"ex_CombinedAssessmentResults_pre_2015"


#' example ex_CombinedAssessmentResults file (formerly Comprehensive Data File)
#'
#' MAP assessment results (**post-2015**), in the format provided by web-based MAP.
#' Data provided from NWEA, by request.  
#' (Note that this is training data, and these students/student records *are not real*!)
#'
#' @format
#' \describe{
#' \item{TermName}{TermName}
#' \item{StudentID}{StudentID}
#' \item{SchoolName}{SchoolName}
#' \item{MeasurementScale}{MeasurementScale}
#' \item{Discipline}{Discipline}
#' \item{GrowthMeasureYN}{GrowthMeasureYN}
#' \item{WISelectedAYFall}{WISelectedAYFall}
#' \item{WISelectedAYWinter}{WISelectedAYWinter}
#' \item{WISelectedAYSpring}{WISelectedAYSpring}
#' \item{WIPreviousAYFall}{WIPreviousAYFall}
#' \item{WIPreviousAYWinter}{WIPreviousAYWinter}
#' \item{WIPreviousAYSpring}{WIPreviousAYSpring}
#' \item{TestType}{TestType}
#' \item{TestName}{TestName}
#' \item{TestID}{TestID}
#' \item{TestStartDate}{TestStartDate}
#' \item{TestDurationMinutes}{TestDurationMinutes}
#' \item{TestRITScore}{TestRITScore}
#' \item{TestStandardError}{TestStandardError}
#' \item{TestPercentile}{TestPercentile}
#' \item{FallToFallProjectedGrowth}{FallToFallProjectedGrowth}
#' \item{FallToFallObservedGrowth}{FallToFallObservedGrowth}
#' \item{FallToFallObservedGrowthSE}{FallToFallObservedGrowthSE}
#' \item{FallToFallMetProjectedGrowth}{FallToFallMetProjectedGrowth}
#' \item{FallToFallConditionalGrowthIndex}{FallToFallConditionalGrowthIndex}
#' \item{FallToFallConditionalGrowthPercentile}{FallToFallConditionalGrowthPercentile}
#' \item{FallToWinterProjectedGrowth}{FallToWinterProjectedGrowth}
#' \item{FallToWinterObservedGrowth}{FallToWinterObservedGrowth}
#' \item{FallToWinterObservedGrowthSE}{FallToWinterObservedGrowthSE}
#' \item{FallToWinterMetProjectedGrowth}{FallToWinterMetProjectedGrowth}
#' \item{FallToWinterConditionalGrowthIndex}{FallToWinterConditionalGrowthIndex}
#' \item{FallToWinterConditionalGrowthPercentile}{FallToWinterConditionalGrowthPercentile}
#' \item{FallToSpringProjectedGrowth}{FallToSpringProjectedGrowth}
#' \item{FallToSpringObservedGrowth}{FallToSpringObservedGrowth}
#' \item{FallToSpringObservedGrowthSE}{FallToSpringObservedGrowthSE}
#' \item{FallToSpringMetProjectedGrowth}{FallToSpringMetProjectedGrowth}
#' \item{FallToSpringConditionalGrowthIndex}{FallToSpringConditionalGrowthIndex}
#' \item{FallToSpringConditionalGrowthPercentile}{FallToSpringConditionalGrowthPercentile}
#' \item{WinterToWinterProjectedGrowth}{WinterToWinterProjectedGrowth}
#' \item{WinterToWinterObservedGrowth}{WinterToWinterObservedGrowth}
#' \item{WinterToWinterObservedGrowthSE}{WinterToWinterObservedGrowthSE}
#' \item{WinterToWinterMetProjectedGrowth}{WinterToWinterMetProjectedGrowth}
#' \item{WinterToWinterConditionalGrowthIndex}{WinterToWinterConditionalGrowthIndex}
#' \item{WinterToWinterConditionalGrowthPercentile}{WinterToWinterConditionalGrowthPercentile}
#' \item{WinterToSpringProjectedGrowth}{WinterToSpringProjectedGrowth}
#' \item{WinterToSpringObservedGrowth}{WinterToSpringObservedGrowth}
#' \item{WinterToSpringObservedGrowthSE}{WinterToSpringObservedGrowthSE}
#' \item{WinterToSpringMetProjectedGrowth}{WinterToSpringMetProjectedGrowth}
#' \item{WinterToSpringConditionalGrowthIndex}{WinterToSpringConditionalGrowthIndex}
#' \item{WinterToSpringConditionalGrowthPercentile}{WinterToSpringConditionalGrowthPercentile}
#' \item{SpringToSpringProjectedGrowth}{SpringToSpringProjectedGrowth}
#' \item{SpringToSpringObservedGrowth}{SpringToSpringObservedGrowth}
#' \item{SpringToSpringObservedGrowthSE}{SpringToSpringObservedGrowthSE}
#' \item{SpringToSpringMetProjectedGrowth}{SpringToSpringMetProjectedGrowth}
#' \item{SpringToSpringConditionalGrowthIndex}{SpringToSpringConditionalGrowthIndex}
#' \item{SpringToSpringConditionalGrowthPercentile}{SpringToSpringConditionalGrowthPercentile}
#' \item{RITtoReadingMin}{RITtoReadingMin}
#' \item{RITtoReadingMax}{RITtoReadingMax}
#' \item{Goal1Name}{Goal1Name}
#' \item{Goal1RitScore}{Goal1RitScore}
#' \item{Goal1StdErr}{Goal1StdErr}
#' \item{Goal1Range}{Goal1Range}
#' \item{Goal1Adjective}{Goal1Adjective}
#' \item{Goal2Name}{Goal2Name}
#' \item{Goal2RitScore}{Goal2RitScore}
#' \item{Goal2StdErr}{Goal2StdErr}
#' \item{Goal2Range}{Goal2Range}
#' \item{Goal2Adjective}{Goal2Adjective}
#' \item{Goal3Name}{Goal3Name}
#' \item{Goal3RitScore}{Goal3RitScore}
#' \item{Goal3StdErr}{Goal3StdErr}
#' \item{Goal3Range}{Goal3Range}
#' \item{Goal3Adjective}{Goal3Adjective}
#' \item{Goal4Name}{Goal4Name}
#' \item{Goal4RitScore}{Goal4RitScore}
#' \item{Goal4StdErr}{Goal4StdErr}
#' \item{Goal4Range}{Goal4Range}
#' \item{Goal4Adjective}{Goal4Adjective}
#' \item{Goal5Name}{Goal5Name}
#' \item{Goal5RitScore}{Goal5RitScore}
#' \item{Goal5StdErr}{Goal5StdErr}
#' \item{Goal5Range}{Goal5Range}
#' \item{Goal5Adjective}{Goal5Adjective}
#' \item{Goal6Name}{Goal6Name}
#' \item{Goal6RitScore}{Goal6RitScore}
#' \item{Goal6StdErr}{Goal6StdErr}
#' \item{Goal6Range}{Goal6Range}
#' \item{Goal6Adjective}{Goal6Adjective}
#' \item{Goal7Name}{Goal7Name}
#' \item{Goal7RitScore}{Goal7RitScore}
#' \item{Goal7StdErr}{Goal7StdErr}
#' \item{Goal7Range}{Goal7Range}
#' \item{Goal7Adjective}{Goal7Adjective}
#' \item{Goal8Name}{Goal8Name}
#' \item{Goal8RitScore}{Goal8RitScore}
#' \item{Goal8StdErr}{Goal8StdErr}
#' \item{Goal8Range}{Goal8Range}
#' \item{Goal8Adjective}{Goal8Adjective}
#' \item{TestStartTime}{TestStartTime}
#' \item{PercentCorrect}{PercentCorrect}
#' \item{ProjectedProficiencyStudy1}{ProjectedProficiencyStudy1}
#' \item{ProjectedProficiencyLevel1}{ProjectedProficiencyLevel1}
#' \item{ProjectedProficiencyStudy2}{ProjectedProficiencyStudy2}
#' \item{ProjectedProficiencyLevel2}{ProjectedProficiencyLevel2}
#' \item{ProjectedProficiencyStudy3}{ProjectedProficiencyStudy3}
#' \item{ProjectedProficiencyLevel3}{ProjectedProficiencyLevel3}
#' }
#' @source NWEA MAP partner support team (thanks!)
"ex_CombinedAssessmentResults"




#' example ex_CombinedStudentsBySchool file (formerly Comprehensive Data File)
#'
#' Roster and demographic records, in the format provided by web-based MAP.
#' Data provided from NWEA, by request.  
#' (Note that this is training data, and these students/student records *are not real*!)
#' 
#' @format
#' \describe{
#' \item{TermName}{TermName}
#' \item{DistrictName}{DistrictName}
#' \item{SchoolName}{SchoolName}
#' \item{StudentLastName}{StudentLastName}
#' \item{StudentFirstName}{StudentFirstName}
#' \item{StudentMI}{StudentMI}
#' \item{StudentID}{StudentID}
#' \item{StudentDateOfBirth}{StudentDateOfBirth}
#' \item{StudentEthnicGroup}{StudentEthnicGroup}
#' \item{StudentGender}{StudentGender}
#' \item{Grade}{Grade}
#' }
#' @source NWEA MAP partner support team (thanks!)
"ex_CombinedStudentsBySchool"


#' ny predicted proficiency 
#'
#' data from implied regression models in the NWEA nyc linking study
#' 
#' @format
#' \describe{
#' \item{ny_subj}{ny_subj}
#' \item{ny_grade}{ny_grade}
#' \item{ny_season}{ny_season}
#' \item{ny_rit}{ny_rit}
#' \item{perf_level}{perf_level}
#' \item{proficient}{proficient}
#' }
#' @source ny_proficiency.Rmd
"ny_predicted_proficiency"
