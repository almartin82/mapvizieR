#' @title prep_cdf_long
#'
#' @description
#' \code{prep_cdf_long} a wrapper around several cdf prep functions
#'
#' @param cdf_long a map assessmentresults.csv file.  can be one term, or many terms
#' together in one file.
#' 
#' @return a prepped cdf file
#' 
#' @export

prep_cdf_long <- function(cdf_long) {
  
  cdf_long <- cdf_long %>% 
    #names
    janitor::clean_names("old_janitor") %>%
    #fallwinterspring, academic_year
    extract_academic_year()
    
  cdf_long$measurementscale <- clean_measurementscale(cdf_long$measurementscale)
  cdf_long$teststartdate <- munge_startdate(cdf_long$teststartdate)
  cdf_long$growthmeasureyn <- as.logical(cdf_long$growthmeasureyn)
  
  assertthat::assert_that(check_cdf_long(cdf_long)$boolean)
  
  return(cdf_long)
}


#' @title process_cdf_long
#'
#' @description
#' \code{process_cdf_long} the second step in cdf processing
#'
#' @param prepped_cdf output of prep_cdf_long
#' @param norms norm study to used.  passed through to consistent percentile
#' 
#' @return a processed cdf file
#' 
#' @export

process_cdf_long <- function(prepped_cdf, norms = 2015) {
  
  munge <- prepped_cdf %>% 
    dedupe_cdf(method = "NWEA") %>%
    grade_level_seasonify() %>%
    grade_season_labelify() %>%
    grade_season_factors() %>%
    make_npr_consistent(norm_study = norms)
  
  #tried to do this with dplyr::mutate but it threw a weird segfault!
  munge$testquartile <- kipp_quartile(munge$consistent_percentile)
  munge$testid <- ifelse(
    is.na(munge$testid), 
    paste(munge$studentid, munge$measurementscale, munge$teststartdate, 
          munge$teststarttime, sep = '_'),
    munge$testid
  )
  
  #group the cdf (for use by the summary method)
  munge <- munge %>% dplyr::group_by(
    measurementscale, map_year_academic, fallwinterspring, 
    termname, schoolname, grade, grade_level_season
  )
  
  #give the cdf a class for method dispatch
  class(munge) <- c("mapvizieR_cdf", class(munge))
  
  return(munge)
}


#' @title dedupe_cdf
#'
#' @description
#' \code{dedupe_cdf} makes sure that the cdf only contains one row student/subject/term 
#'
#' @param prepped_cdf conforming prepped cdf file.
#' @param method can choose between c('NWEA', 'high RIT', 'most recent').  
#' Default is NWEA method.
#' 
#' @return a data frame with one row per kid
#' 
#' @export

dedupe_cdf <- function(prepped_cdf, method="NWEA") {
  #verify inputs
  assertthat::assert_that(
    is.data.frame(prepped_cdf),
    method %in% c("NWEA", "high RIT", "most recent"),
    check_cdf_long(prepped_cdf)$boolean
  )

  #dedupe using dplyr arrange and row_number
  #the ranking criteria determines which record to keep when there are duplicates
  dupe_tagged <- prepped_cdf %>%
    dplyr::group_by(studentid, measurementscale, map_year_academic, fallwinterspring)

  #apply the appropriate ranking method
  if (method == "NWEA") {
    #NWEA method: prefer growthmeasureyn = "Yes", then lowest standard error
    dupe_tagged <- dupe_tagged %>%
      dplyr::arrange(
        dplyr::desc(.data$growthmeasureyn),
        .data$teststandarderror,
        .by_group = TRUE
      )
  } else if (method == "high RIT") {
    #prefer highest RIT score
    dupe_tagged <- dupe_tagged %>%
      dplyr::arrange(dplyr::desc(.data$testritscore), .by_group = TRUE)
  } else if (method == "most recent") {
    #prefer most recent test date
    dupe_tagged <- dupe_tagged %>%
      dplyr::arrange(dplyr::desc(.data$teststartdate), .by_group = TRUE)
  }

  #assign row number within each group
  dupe_tagged <- dupe_tagged %>%
    dplyr::mutate(rn = dplyr::row_number())

  #keep only the first row in each group
  deduped <- dupe_tagged[dupe_tagged$rn == 1, ]

  return(deduped)
}



#' @title grade_level_seasonify
#'
#' @description
#' \code{grade_level_seasonify} turns grade level into a simplified continuous scale, 
#' using consistent offsets for MAP 'seasons'  
#'
#' @param cdf a cdf that has 'grade' and 'fallwinterspring' columns (eg product of )
#' \code{grade_levelify()}
#' 
#' @return a data frame with a 'grade_level_season' column

grade_level_seasonify <- function(cdf) {

  #inputs consistency check
  if (!all(c('grade', 'fallwinterspring') %in% names(cdf))) {
    cli::cli_abort("'grade' and 'fallwinterspring' must be in in your cdf to grade_seasonify")
  }

  season_offsets <- data.frame(
    season=c('Fall', 'Winter', 'Spring', 'Summer'),
    offset=c(-0.8, -0.5, 0, 0.1),
    stringsAsFactors = FALSE
  )
  
  #get the offset
  munge <- dplyr::left_join(
    x = cdf,
    y = season_offsets,
    by = c('fallwinterspring' = 'season')
  )
  
  munge %>%
    dplyr::mutate(
      grade_level_season = grade + offset
    ) %>%
    dplyr::select(-offset) %>%
    as.data.frame()
}



#' @title grade_season_labelify
#'
#' @description
#' \code{grade_season_labelify} returns an abbreviated label ('5S') that is useful when
#' labelling charts  
#'
#' @param x a cdf that has 'grade_level_season' (eg product of grade_level_seasonify)
#' \code{grade_levelify()}
#' 
#' @return a data frame with a grade_season_labels

grade_season_labelify <- function(x) {
  
  assertthat::assert_that('grade_level_season' %in% names(x))
  x$grade_season_label <- fall_spring_me(x$grade_level_season)
    
  return(as.data.frame(x))
}



#' @title grade_season_factors
#' 
#' @description helper function that 1) converts grade_season_label to factor and
#' 2) orders the labels based on grade_level_season
#' 
#' @param x a cdf that has grade_level_season and grade_season_label

grade_season_factors <- function(x) {
  
  x$grade_season_label <- factor(
    x$grade_season_label,
    levels = unique(x[order(x$grade_level_season),]$grade_season_label),
    ordered = TRUE  
  )
  
  return(x)
}



#' @title make_npr_consistent
#' 
#' @description join a cdf to a norms study and get the empirical 
#' percentiles.  protects against longitudinal findings being 
#' clouded by changes in the norms.
#' 
#' @param cdf a mostly-processed cdf object (this is the last step)
#' in process_cdf
#' @param norm_study c(2011, 2015).  year a norm study.  default is 2015.  look in norm_data.R
#' for documentation of available norm studies.

make_npr_consistent <- function(
  cdf,
  norm_study = 2015
) {
  #make sure that cdf has required fields
  ensure_fields(
    c('measurementscale', 'fallwinterspring', 'grade', 'testritscore'),
    cdf
  )
      
  if (norm_study == 2011) {
    norm_df <- student_status_norms_2011
  } else if (norm_study == 2015) {
    norm_df <- status_norms_2015
  }
  
  names(norm_df)[names(norm_df) == 'student_percentile'] <- 'consistent_percentile'
  norm_df$percentile_source <- paste0('status_norms_', norm_study)
  
  norm_df <- norm_df %>%
    dplyr::select(
      measurementscale, fallwinterspring, grade, RIT, consistent_percentile
    )
  
  out <- dplyr::left_join(
    x = cdf,
    y = norm_df,
    by = c(
      "measurementscale" = "measurementscale",
      "fallwinterspring" = "fallwinterspring",
      "grade" = "grade",
      "testritscore" = "RIT"
    )
  )
  
  if (nrow(out) > nrow(cdf)) {
    stop('check consistent percentile.  the join appears to be incorrect.')
  }
  
  out
}


#' identify type of cdf from AssessmentResults file.
#'
#' @param cdf an Assessment Results data frame.
#'
#' @return one of "Client-Server", "WBM pre-2015", "WBM post-2015"
#' @export
#' @examples
#' data(ex_CombinedAssessmentResults)
#' id_cdf_type(ex_CombinedAssessmentResults)
#' 
#' data(ex_CombinedAssessmentResults_pre_2015)
#' id_cdf_type(ex_CombinedAssessmentResults_pre_2015)
id_cdf_type <- function(cdf){
  
  # determine if CDF is client serve or WBM
  names(cdf) <- tolower(names(cdf))
  if (any(grepl("^(fall|winter|spring) \\d{4}$", tolower(cdf$termname)))) {
    cdf_type <- "Client-Server"
  } else {
    # deterime if WBM CDF is pre or post 2015
    cdf_col_names <- tolower(names(cdf))
    if ("typicalfalltospringgrowth" %in% cdf_col_names) {
      cdf_type <- "WBM pre-2015"
    } else {
      if ("falltofallprojectedgrowth" %in% cdf_col_names) {
        cdf_type <- "WBM post-2015"
        } else { 
          cdf_type <- "unknown"
        }
      }
    }
    
  # return type
 cdf_type 
}

#' Migrate pre-2015 CDFs  (both client-server nad WBM) to post-2015 specification,
#'
#' @param cdf the Assessment Results table from a Comprehensive Data file as a data.frame
#'
#' @return a data.frame of the Assessment Results table in the post-2015 CDF format
#' @export
migrate_cdf_to_2015_std <- function(cdf){

  

  
  cdf_type <- id_cdf_type(cdf)
  if (cdf_type == "unknown") stop("Unknown cdf type, so I can't migrate it.")
  
  # Change termname if client-server type
  if (cdf_type == "Client-Server") {
    original_names <- names(cdf)
    names(cdf) <- tolower(names(cdf))
    message("Migrating client-server CDF to pre-2015 WBM CDF . . .")    
    cdf  <- cdf %>%
      dplyr::mutate(season = stringr::str_extract(termname, "\\w+"),
                    yr = as.numeric(stringr::str_extract(termname, "\\d{4}")),
                    termname = ifelse(tolower(season) == "fall",
                                      paste0(season, " ", yr, "-", yr+1),
                                      paste0(season, " ", yr-1, "-", yr))
                    ) %>%
    dplyr::select(-season, -yr)
  
    names(cdf) <- original_names
    
  
    cdf_type <- id_cdf_type(cdf)
    if (cdf_type == "unknown") stop("Unknown cdf type, so I can't migrate it.")
    
    }
  
  # Migrate pre-2015 WBM cdf to post-2015
  if (cdf_type == "WBM pre-2015"){
    message("Migrating pre-2015 WBM CDF to post-2015 WBM CDF . . .")
    cdf <- cdf %>%
     dplyr::mutate(NormsReferenceData= NA,
             WISelectedAYFall = NA,
             WISelectedAYWinter = NA,	
             WISelectedAYSpring	= NA,
             WIPreviousAYFall	= NA,
             WIPreviousAYWinter = NA,	
             WIPreviousAYSpring = NA,
        
             FallToFallProjectedGrowth = TypicalFallToFallGrowth,	
             FallToFallObservedGrowth = NA,
             FallToFallObservedGrowthSE = NA,
             FallToFallMetProjectedGrowth = NA,
             FallToFallConditionalGrowthIndex = NA,
             FallToFallConditionalGrowthPercentile = NA,
             
             FallToWinterProjectedGrowth = TypicalFallToWinterGrowth,	
             FallToWinterObservedGrowth = NA,
             FallToWinterObservedGrowthSE = NA,
             FallToWinterMetProjectedGrowth = NA,
             FallToWinterConditionalGrowthIndex = NA,
             FallToWinterConditionalGrowthPercentile = NA,
             
             FallToSpringProjectedGrowth = TypicalFallToSpringGrowth,	
             FallToSpringObservedGrowth = NA,
             FallToSpringObservedGrowthSE = NA,
             FallToSpringMetProjectedGrowth = NA,
             FallToSpringConditionalGrowthIndex = NA,
             FallToSpringConditionalGrowthPercentile = NA,
             
             WinterToWinterProjectedGrowth = NA,	
             WinterToWinterObservedGrowth = NA,
             WinterToWinterObservedGrowthSE = NA,
             WinterToWinterMetProjectedGrowth = NA,
             WinterToWinterConditionalGrowthIndex = NA,
             WinterToWinterConditionalGrowthPercentile = NA,
             
             WinterToSpringProjectedGrowth = NA,	
             WinterToSpringObservedGrowth = NA,
             WinterToSpringObservedGrowthSE = NA,
             WinterToSpringMetProjectedGrowth = NA,
             WinterToSpringConditionalGrowthIndex = NA,
             WinterToSpringConditionalGrowthPercentile = NA,
             
             SpringToSpringProjectedGrowth = TypicalSpringToSpringGrowth,	
             SpringToSpringObservedGrowth = NA,
             SpringToSpringObservedGrowthSE = NA,
             SpringToSpringMetProjectedGrowth = NA,
             SpringToSpringConditionalGrowthIndex = NA,
             SpringToSpringConditionalGrowthPercentile = NA,
             
             ProjectedProficiencyStudy1 = NA,
             ProjectedProficiencyLevel1 = ProjectedProficiency,
             ProjectedProficiencyStudy2 = NA,
             ProjectedProficiencyLevel2 = NA,
             ProjectedProficiencyStudy3 = NA,
             ProjectedProficiencyLevel3 = NA
      ) %>%
      dplyr::select(TermName:GrowthMeasureYN,
             WISelectedAYFall:WIPreviousAYSpring,
             TestType:TestPercentile,
             FallToFallProjectedGrowth:SpringToSpringConditionalGrowthPercentile,
             RITtoReadingScore:PercentCorrect,
             ProjectedProficiencyStudy1:ProjectedProficiencyLevel3
      )
  }
  
  # return
  as.data.frame(cdf)

}
