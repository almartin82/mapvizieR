#' @title lower_df_names
#'
#' @description
#' \code{lower_df_names} a utility function to take a data frame and return it with 
#' lowercase names
#'
#' @param x a data frame
#' 
#' @return data frame with modified names

lower_df_names <- function(x) {
  
  names(x) <- tolower(names(x))
  
  return(x)
}



#' @title extract_academic_year
#'
#' @description
#' \code{extract_academic_year} break up the termname field into year and fallwinterspring
#'
#' @param x a data frame
#' 
#' @return data frame with disambiguated termname and map_year_academic
#' 
extract_academic_year <- function(x) {
  
  prep1 <- do.call(
    what = rbind,
    args = strsplit(x = x$termname, split = " ", fixed = T)
  )
  
  x$fallwinterspring <- prep1[ ,1]

  #the academic year of the test date
  prep2 <- do.call(
    what = rbind,
    args = strsplit(x = prep1[ , 2], split = "-", fixed = T)
  )
  
  #coerce to numeric
  x$map_year_academic <- as.integer(prep2[ ,1])
  
  return(x)
}

#' @title Create vector of Initials
#'
#' @description
#' \code{abbrev} returns a character vector of each words first capital letters for each element of \code{x}.
#'
#' @details 
#' This function returns a same-length character vector
#' that abbrevs an initial character vector, \code{x}.  Abbreviation returns the first
#' capital letter of any words in each element of \code{x}.  Users may additionally pass
#' \code{abbrev} an optional list of exceptions that overides the default abbreviations.
#' The list of exceptions requires a vector of "old" values to be replaced by "new" values
#' 
#' @param x vector of strings to be abbreviated.
#' @param exceptions list with two names vectors:  \code{old}, a vector abbreviations to 
#' be replaced and  \code{new}, a vector of replacment values.
#' 
#' @return a character vector of \code{length(x)}.
#' @export
#' @examples 
#' x<-c("KIPP Ascend Middle School", "KIPP Ascend Primary School", 
#'      "KIPP Create College Prep", 
#'      "KIPP Bloom College Prep" ,
#'      "KIPP One Academy")
#' 
#' abbrev(x)
#' 
#' altnames<-list(old=c("KAPS", "KBCP", "KOA"), 
#'                  new=c("KAP", "Bloom", "One"))
#' 
#' abbrev(x, exceptions=altnames)

abbrev<-function(x, exceptions=NULL){
  x.out<- gsub(pattern="(\\w)\\w*\\W*", 
               replacement="\\1",
               x=x)
  
  # pass list of exceptions to the abbrev function
  if(!is.null(exceptions)){
    x.changed<-with(exceptions, new[match(x.out, old)]) # create changes vector (non changes = NA)
    x.changed[is.na(x.changed)]<-x.out[is.na(x.changed)] # replace NAs with non-changed values
    x.out<-x.changed # replace original vector with changed vector               
  }
  
  
  x.out
}

#' @title Calcualte KIPP Foundation style quartiles from percentile vector
#'
#' @description
#' \code{kipp_quartile} returns an integer or factor vector quartiles.  
#'
#' @details 
#' This function calculates the KIPP Foundation's (kinda fucked up) quartile (i.e., the foundation
#' breaks with stanard mathematical pracitce and puts the 50th percenile
#' in the  3rd rather than the 2nd quartile). It takes a vector of percentiles and translates 
#' those into quartiles, where the 25th, 50th, and 75th percentils are shifted up 
#' into the 2nd, 3rd, and 4th quartiles, respectively. You can revert to a traditional 
#' quartile calculation by setting the \code{proper.quartile} argument to \code{TRUE}.
#' 
#' @param x vector of percentiles to be converted to quartiels
#' @param return.factor  default is \code{TRUE}.  If set to \code{FALSE} returns integers rather than factors. 
#' @param proper.quartile defaul is \code{FALSE}.  If set to \code{TRUE} returns traditional quartiles rather then KIPP Foundation quartiles. 
#' 
#' @return a vector of \code{length(x)}.
#' @export
#' @examples 
#' x <- sample(x=1:99, 100,replace = TRUE)
#' kipp_quartile(x)
#' kipp_quartile(x, proper.quartile=TRUE)
#' kipp_quartile(x, proper.quartile=TRUE, return.factor=FALSE)

kipp_quartile<- function(x, 
                         return.factor=TRUE, 
                         proper.quartile=FALSE){
  
  
  #defactor factors
  if(is.factor(x)) x<-as.numeric(as.character(x))
  
  # Error handling 
  stopifnot(x>0 | is.na(x), x<100 | is.na(x))
  
  # if proper.quartile is false adjust x's to return Foundation quartile 
  if(!proper.quartile) x<-x+1
  #calculate quartile
  y<-ceiling(x/25)
  
  #transform to factor
  if(return.factor) y<-factor(y, levels=c(1:4))
  
  #return
  y
}


#' @title Calculate KIPP Tiered Growth factors 
#'
#' @description
#' \code{tiered_growth_factors} takes grade level and quartile data and returns a vector of KIPP 
#' Tiered Growth factors (or multipliers, if you prefer).
#' @details 
#'  # Function takes two vectors---one containing student grade levels and the other 
#'  containing student pre-test/season 1 quartiles---and returns a same-length vector of 
#'  KIPP Tired Growth factors.  These factors are multiplied by a students typical 
#'  (i.e., expected) growth to generate college ready growth. 

#' 
#' @param quartile a vector of student quartiles 
#' @param grade vector of student grade-levels
#' 
#' @return a vector of \code{length(quartile)} of KIPP Tiered Growth factors.
#' @export

tiered_growth_factors <- function(quartile, grade){
  
  #Error handling 
  stopifnot(length(quartile)==length(grade))
  
  # Create data.frame lookup of KIPP Foundation Growth Targts
  tgrowth<-data.frame(grade.type=c(rep(0,4),rep(1,4)), 
                      quartile = as.factor(rep(1:4, 2)), 
                      KIPPTieredGrowth=c(1.5,1.5,1.25,1.25,2,1.75,1.5,1.25)
  )
  
  #
  grade.type<-rep(NA,times=length(quartile))
  
  # Create Grade Type column
  grade.type<-ifelse(grade<=3, 0,1)
  
  df<-data.frame(grade, grade.type, quartile=as.factor(quartile))
  
  df2<-left_join(df, tgrowth, by=c("quartile", "grade.type"))
  
  #return
  df2$KIPPTieredGrowth
  
}

#' @title Standardize Kindergarten code to 0 and other grades to integers
#'
#' @description
#' \code{standardize_kinder} returns an integer vector grade levels.  
#'
#' @details 
#' This function simply translates kindergarten codes 13 (from client-based
#' MAP), "K", or a user specified \code{kinder_code} from an input vector \code{x}
#'  to 0 and recasts the  input vector to an integer vector. 
#' @param x a character, integer, or numeric vector of grade levels
#' @param other_codes a vector of alternative codes for kindergarten to be translated to 0  
#' 
#' @return an integer vector of \code{length(x)}.
#' @export
#' @examples 
#' 
#' # Create vector of grades 1 through 13, where 13 = kinder
#' x <- sample(x=1:13, 100,replace = TRUE)
#' standardize_kinder(x)
#' 
#' # change 13 to "K"
#' x2 <- ifelse(x==13, "K", x)
#' standardize_kinder(x2)
#' 
#' # change "K" to "Kinder"
#' x3 <- ifelse(x=="K", "Kinder", x)
#' standardize_kinder(x2, other_codes="Kinder")


standardize_kinder<- function(x,
                              other_codes=NULL){
  
  # use other codes first
  if(!is.null(other_codes)){
    x<-ifelse(x %in% other_codes, 0, x)
  }
  
  # change "K" to 0
  x <- ifelse(x=="K", 0, x)
  
  # change 13 to 0
  x <- ifelse(x==13, 0, x)
  
  # cast as integer.vector
  x<-as.integer(x)
   
  #return 
  x
}



#' @title grade_level_season
#' 
#' @description returns appropriate offset given a season
#' 
#' @param season 'Fall', 'Winter', 'Spring', or 'Summer'.
#' 
#' @return decimal offset that matches the season

grade_level_season <- function(season) {
  
  assert_that(length(season)==1)
  assert_that(season %in% c('Fall', 'Winter', 'Spring', 'Summer'))
  
  season_offsets <- list(
    'Fall' = -0.8
   ,'Winter' = -0.5
   ,'Spring' = 0
   ,'Summer' = 0.1
  )
  
  return(season_offsets[[season]])
}

#' @title grade_level_seasonify
#'
#' @description
#' \code{grade_level_seasonify} turns grade level into a simplified continuous scale, 
#' using consistent offsets for MAP 'seasons'  
#'
#' @param x a cdf that has 'grade' and 'fallwinterspring' columns (eg product of )
#' \code{grade_levelify()}
#' 
#' @return a data frame with a 'grade_level_season' column

grade_level_seasonify <- function(x) {
  
  assert_that('grade' %in% names(x))
  assert_that('fallwinterspring' %in% names(x))
  
  prepped <- x %>% 
    rowwise() %>%
    mutate(
      grade_level_season = grade + grade_level_season(fallwinterspring)
    )
  
  return(as.data.frame(prepped))
}



#' @title Fall-Spring Me
#'
#' @description
#' \code{fall_spring_me} tranforms grade levels into labels for charts; eg 4.2 -> F5
#'
#' @param grade_season a grade level between -1 and 12
#' 
#' @return a labeled string
#' @export
#' 

fall_spring_me <- function(grade_season) {
  
  #K is weird edge case
  if(grade_season == -0.8) {
    return('KF')
  } else if(grade_season == -0.5) {
    return('KW')
  } else if(grade_season == 0) {
    return('KS')
  #too small, return nothing
  } else if(grade_season <= -1) {
    return('')
  #too big
  } else if(grade_season > 12) {
    return('')  
  #S observations are decimal 0s
  } else if(grade_season %% 1 == 0) {
    return(paste0(round(grade_season, 0), 'S'))
  #test for F and W
  } else if(round(grade_season %% 1,1) == 0.2) {
    return(paste0(floor(grade_season) + 1, 'F'))
  } else if(round(grade_season %% 1,2) == 0.5) {
    return(paste0(floor(grade_season) + 1, 'W'))
  } else {
    return(NA)
  }
}



#' @title round_to_any
#' 
#' @description because we don't want \code{suggests: plyr, dpylr if we can avoid it}
#' 
#' @param x numeric or date-time (POSIXct) vector to round
#' @param accuracy number to round to; for POSIXct objects, a number of seconds
#' @param f rounding function: \code{\link{floor}}, \code{\link{ceiling}} or
#'  \code{\link{round}}

round_to_any <- function(x, accuracy, f = round) {
  f(x / accuracy) * accuracy
}
