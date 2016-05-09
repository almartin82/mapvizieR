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



#' @title build_year_in_district
#'
#' @description tags the roster with the student's year in the district
#' 
#' @param roster a roster data frame. must contain studentid, map_year_academic,
#' and grade
#' 
#' @return data frame with disambiguated termname and map_year_academic

build_year_in_district <- function(roster) {
  
  district_year <- roster %>% 
    dplyr::select(studentid, map_year_academic, grade) %>% 
    unique() %>% dplyr::tbl_df() %>%
    dplyr::arrange(
      studentid, map_year_academic, grade
    ) %>%
    dplyr::mutate(
      year_in_district = rank(map_year_academic, ties.method = 'first')
    )
  roster <- roster %>%
    dplyr::left_join(
      district_year,
      by = c('studentid', 'map_year_academic', 'grade')
    )
  
  return(roster)
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

abbrev <- function(x, exceptions = NULL){
  x.out <- gsub(pattern = "(\\w)\\w*\\W*", 
               replacement = "\\1",
               x = x)
  
  # pass list of exceptions to the abbrev function
  if (!is.null(exceptions)) {
    x.changed <- with(exceptions, new[match(x.out, old)]) # create changes vector (non changes = NA)
    x.changed[is.na(x.changed)] <- x.out[is.na(x.changed)] # replace NAs with non-changed values
    x.out <- x.changed # replace original vector with changed vector               
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
#' @param return_factor  default is \code{TRUE}.  If set to \code{FALSE} returns integers rather than factors. 
#' @param proper_quartile defaul is \code{FALSE}.  If set to \code{TRUE} returns traditional quartiles rather then KIPP Foundation quartiles. 
#' 
#' @return a vector of \code{length(x)}.
#' @export
#' @examples 
#' x <- sample(x=1:99, 100,replace = TRUE)
#' kipp_quartile(x)
#' kipp_quartile(x, proper_quartile=TRUE)
#' kipp_quartile(x, proper_quartile=TRUE, return_factor=FALSE)

kipp_quartile <- function(x, return_factor = TRUE, proper_quartile = FALSE){
  
  #defactor factors
  if (is.factor(x)) x <- as.numeric(as.character(x))
  
  # Error handling 
  stopifnot(x > 0 | is.na(x), x < 100 | is.na(x))
  
  # if proper.quartile is false adjust x's to return Foundation quartile 
  if (!proper_quartile) x <- x + 1
  #calculate quartile
  y <- ceiling(x/25)
  
  #transform to factor
  if (return_factor) y <- factor(y, levels = c(1:4))
  
  #return
  y
}



#' ad-hoc psuedo quartile
#'
#' @description can be used to get becca plot to return predicted performance 
#' bands, instead of quartile bands 
#' @param vector to compare (presumably percentile ranks)
#' @param breaks vector of breaks
#'
#' @return vector of 'quartiles'
#' @export

adhoc_psuedo_quartile <- function(x, breaks) {
  expanded_long <- expand.grid(x, breaks)
  expanded_long$group_label <- paste0('group_', seq(1:length(x)))
  expanded_long$test <- expanded_long$Var1 > expanded_long$Var2
  out <- expanded_long %>%
    dplyr::group_by(group_label) %>%
    dplyr::summarize(
      psuedo_quartile = sum(test)
    )
  out$psuedo_quartile + 1
}



#' ny state psuedo-quartiles
#'
#' @param x vector to compare (presumably percentile ranks)
#'
#' @return vector of 'quartiles'
#' @export
nys_math_3 <- function(x) adhoc_psuedo_quartile(x, c(28, 56, 78))

#' @export
#' @rdname nys_math_3
nys_math_4 <- function(x) adhoc_psuedo_quartile(x, c(29, 65, 90))

#' @export
#' @rdname nys_math_3
nys_read_3 <- function(x) adhoc_psuedo_quartile(x, c(41, 72, 93))

#' @export
#' @rdname nys_math_3
nys_read_4 <- function(x) adhoc_psuedo_quartile(x, c(40, 73, 88))


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
  stopifnot(length(quartile) == length(grade))
  
  # Create data.frame lookup of KIPP Foundation Growth Targts
  tgrowth <- data.frame(
    grade.type = c(rep(0,4),rep(1,4)), 
    quartile = as.factor(rep(1:4, 2)), 
    KIPPTieredGrowth = c(1.5,1.5,1.25,1,2,1.75,1.5,1)
  )
  
  grade.type <- rep(NA, times = length(quartile))
  
  # Create Grade Type column
  grade.type <- ifelse(grade <= 3, 0, 1)
  
  df <- data.frame(grade, grade.type, quartile = as.factor(quartile))
  
  df2 <- dplyr::left_join(df, tgrowth, by = c("quartile", "grade.type"))
  
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

standardize_kinder <- function(x, other_codes = NULL){
  
  # use other codes first
  if (!is.null(other_codes)) {
    x <- ifelse(x %in% other_codes, 0, x)
  }
  
  # change "K" to 0
  x <- ifelse(x == "K", 0, x)
  
  # change 13 to 0
  x <- ifelse(x == 13, 0, x)
  
  # cast as integer.vector
  x <- as.integer(x)
   
  #return 
  x
}



#' @title fall_spring_me
#'
#' @description
#' \code{fall_spring_me} tranforms grade levels into labels for charts; eg 4.2 -> F5
#'
#' @param x a grade level between -1 and 12
#' 
#' @return a labeled string
#' @export

fall_spring_me <- function(x) {
  
  #make the df
    #just the grades
    gr_spr <- c(0:12)
    gr_fall <- gr_spr - 0.8
    gr_wint <- gr_spr - 0.5

    with_k <- c('K', gr_spr[2:13])
    #just the labels
    labels_spr <- paste0(with_k, 'S')
    labels_fall <- paste0(with_k, 'F')
    labels_wint <- paste0(with_k, 'W')
  
  labels_df <- data.frame(
    grade_level_season = c(gr_spr, gr_fall, gr_wint),
    grade_season_label = c(labels_spr, labels_fall, labels_wint),
    stringsAsFactors = FALSE
  )
  
  input_df <- data.frame(
    grade_level_season = x,
    stringsAsFactors = FALSE
  )
  
  munge <- dplyr::left_join(
    x = input_df,
    y = labels_df,
    by = c('grade_level_season' = 'grade_level_season')
  )
  
  #return as vector
  munge$grade_season_label
}



#' @title round_to_any
#' 
#' @description because we don't want to have to suggest plyr, if we can avoid it.
#' 
#' @param x numeric or date-time (POSIXct) vector to round
#' @param accuracy number to round to; for POSIXct objects, a number of seconds
#' @param f rounding function: \code{\link{floor}}, \code{\link{ceiling}} or
#'  \code{\link{round}}
#'  
#' @return a numeric vector
#' @export

round_to_any <- function(x, accuracy, f = round) {
  f(x / accuracy) * accuracy
}


#' @title df_sorter
#' 
#' @description helper function used by report_dispatcher
#' 
#' @param x data frame to sort
#' @param by how to sort
#' @param decreasing logical toggle to change sort order
#' @param ... additional arguments

df_sorter <- function(x, by = 1, decreasing = FALSE, ... ) {
  f <- function(...) order(..., decreasing = decreasing)
  i <- do.call(f, x[by])
  x[i, , drop = FALSE]
}



#' @title is_error
#' 
#' @description utility function, test if an object is a try-error
#' 
#' @param x an object

is_error <- function(x) {
  inherits(x, "try-error")
}



#' @title is_not_error
#' 
#' @description utility function, test if an object is NOT a try-error
#' 
#' @param x an object

is_not_error <- function(x) {
  !is_error(x)
}



#' @title rand_stu
#' 
#' @description gives back a random sample of studentids from a mapvizieR object
#' 
#' @param mapvizieR_obj conforming mapvizieR object
#' @param low how many kids? lower bound
#' @param high how many kids? higher bound

rand_stu <- function(mapvizieR_obj, low = 20, high = 500) {
  sample(mapvizieR_obj[['roster']]$studentid, sample(low:high, 1)) %>% 
      unique 
}



#' @title clean_measurementscale
#' 
#' @description add any logic about cleaning measurementscales to this function
#' 
#' @param x a measurementscale

clean_measurementscale <- function(x) {
  
  x <- ifelse(x == 'Science - General Science', 'General Science', x) 
  x <- ifelse(x == 'Science - Concepts and Processes', 'Concepts and Processes', x) 

  return(x)
}



#' @title munge_startdate
#' 
#' @description helper function to convert a variety of date formats cleanly
#' 
#' @param x teststartdate field

munge_startdate <- function(x) {
  as.Date(
    lubridate::parse_date_time(x, c("ymd", "mdy", "%d%m%Y"))
  )
}



#' @title mv_opening_checks
#' 
#' @description common beginning checks when building a plot.  DRY, right?
#' 
#' @param mapvizieR_obj a valid mapvizieR object.
#' @param studentids vector of studentids to run for this plot
#' @param min_stu minimum number of students for this plot.  default is 1.
#' 
#' @export

mv_opening_checks <- function(mapvizieR_obj, studentids, min_stu = 1) {
  #has to be a mapvizieR obj
  mapvizieR_obj %>% ensure_is_mapvizieR()
  
  #gotta have this many kids
  studentids %>% 
    ensurer::ensure_that(
      length(.) > min_stu ~ paste("this plot requires at least", min_stu, "student.")
    )
  
  mapvizieR_obj[['cdf']] %>%  
    ensurer::ensure_that(
      check_cdf_long(.)$boolean == TRUE ~ "your mapvizieR CDF is not conforming."
    )
}


    
#' @title valid_grade_seasons
#' 
#' @description a filter on a cdf that restricts the grade_level_season ONLY to 
#' spring data, and fall of 'entry' grades 
#' 
#' @param cdf a processed cdf
#' @param first_and_spring_only should we limit only to 'entry' grades
#' @param entry_grade_seasons which grade seasons are 'entry' for this school?
#' @param detail_academic_year what is the 'current' year?  never drop data for
#' this year.

valid_grade_seasons <- function(
  cdf, 
  first_and_spring_only = TRUE,
  entry_grade_seasons = c(-0.8, 4.2), 
  detail_academic_year = 2014
) {
  #only these seasons
  if (first_and_spring_only) {
    valid_grade_seasons <- c(entry_grade_seasons, 0, seq(0:11))
  } else {
    valid_grade_seasons <- unique(cdf$grade_level_season)
  }
  
  #only valid grade level seasons or detail year
  cdf %>%
    dplyr::filter(
      round(grade_level_season, 1) %in% round(valid_grade_seasons, 1) | 
        map_year_academic == detail_academic_year
    ) 
}



#' @title mv_limit_cdf
#' 
#' @description extract the cdf and limit it to target students
#' 
#' @param mapvizieR_obj a conforming mapvizieR object
#' @param studentids vector of studentids
#' @param measurementscale a MAP subject
#' 
#' @return the cdf
#' 
#' @export

mv_limit_cdf <- function(mapvizieR_obj, studentids, measurementscale) {
  #nse
  measurementscale_in <- measurementscale
  
  #extract the object
  cdf_long <- mapvizieR_obj[['cdf']] 
  #only these kids
  out <- cdf_long %>%
    dplyr::filter(
      studentid %in% studentids,
      measurementscale == measurementscale_in
    ) %>%
    dplyr::tbl_df()
  
  return(out)
}



#' @title mv_limit_growth_df
#' 
#' @description extract the growth df and limit it to target students
#' @inheritParams mv_limit_cdf
#' 
#' @export

mv_limit_growth <- function(mapvizieR_obj, studentids, measurementscale) {
  measurementscale_in <- measurementscale
  
  #extract the object
  growth_df <- mapvizieR_obj[['growth_df']]
  #only these kids
  growth_df %>%
    dplyr::filter(
      studentid %in% studentids &
      measurementscale %in% measurementscale_in
    )  
}


#' @title min_term_filter 
#' 
#' @description returns only grade_season data where the number of students represented is at
#' least N% of the total
#' 
#' @param cdf conforming cdf
#' @param small_n_cutoff anything below this percent will get filtered out.  
#' default is -1, eg off

min_term_filter <- function(cdf, small_n_cutoff = -1) {
   
  grade_seasons_to_keep <- cdf %>%
    dplyr::group_by(grade_level_season) %>%
    dplyr::summarize(
      n = n()
    ) %>%
    dplyr::mutate(
      include = n >= max(n) * small_n_cutoff
    ) %>%
    dplyr::filter(
      include == TRUE
    ) %>%
    dplyr::select(
      grade_level_season  
    ) %>%
    as.data.frame()
 
  cdf %>%
    dplyr::filter(
      grade_level_season %in% as.numeric(grade_seasons_to_keep$grade_level_season)
    )  
}


#' @title min_subgroup_filter 
#' 
#' @description given a data frame and some arbitrary subgroup, 
#' return only the rows that are members of subgroups that make up
#' at least n % of the total data frame
#' 
#' @param df some data frame
#' @param subgroup_name of a column of the data frame
#' @param small_n_cutoff anything below this percent will get filtered out.  
#' default is -1, eg off

min_subgroup_filter <- function(df, subgroup_name, small_n_cutoff = -1) {
  
  #defensive against dplyr output
  df <- as.data.frame(df)
  
  #more assumptions
  df %>% 
    ensurer::ensure_that(
      subgroup_name %in% names(.) ~ 
      "the subgroup you specified isn't in the data frame you provided"
    )

  #counts and percentages
  to_keep <- df %>%
    dplyr::select_(
      quote(studentid),
      subgroup_name
    ) %>%
    dplyr::group_by_(
      subgroup_name
    ) %>%
    #how many
    dplyr::summarize(
      n = n()
    ) %>%
    #is it bigger than the cutoff
    dplyr::mutate(
      include = n >= max(n) * small_n_cutoff
    ) %>%
    #filter to get only the groups that match
    dplyr::filter(
      include == TRUE
    ) %>%
    #only the name of the subgroup
    dplyr::select_(
      subgroup_name
    ) %>% unlist() %>% unname()
  
  #filter the df and return
  mask <- df[, subgroup_name] %in% to_keep
  df[mask, ] %>% as.data.frame()
}



#' @title quartile_order
#' 
#' @description helper function used by becca plot to put quartiles in correct order
#' 
#' @param x a quartile (1-4)

quartile_order <- function(x) { 
  ifelse(x == 2, 1,
    ifelse(x == 1, 2, x)       
  )
}



#' @title time_execution
#' 
#' @description times how long it takes to execute a function
#' 
#' @param n num times to run the function
#' @param test_function name of the function, passed to do.call
#' @param test_args list of arguments for the function, passed
#' to do.call
#' @export

time_execution <- function(n, test_function, test_args) {
  timings <- rep(NA, n)
 
  for (itr in 1:n) {
    start <- Sys.time()
    do.call(
      what = test_function, 
      args = test_args
    )
    end <- Sys.time()
    timings[itr] <- end - start
  }
 
  return(timings)
}
 
#' @title n_timings
#' 
#' @description a convenience wrapper around timings to record
#' the results of timing a function's execution
#' 
#' @inheritParams time_execution
#' 
#' @export

n_timings <- function(n, test_function, test_args) {
  timings <- time_execution(n, test_function, test_args)
  
  result <- paste0(
    n, " trials of ", test_function, " with mean time of ", 
    round(mean(timings), 4), " seconds.\n", 
    "min of ", round(min(timings), 4), " and max of ",
    round(max(timings), 4), " seconds."
  )
  
  cat(result)
}



#' @title ensure_fields
#' 
#' @description a simple wrapper around ensurer to check for necessary fields
#' used by a function
#' 
#' @param fields_vector vector of fields that your function needs.
#' @param df data frame that needs to have the fields

ensure_fields <- function(fields_vector, df) {
  
  df %>%
  ensurer::ensure_that(
    all(fields_vector %in% names(df)) ~ paste(
      "this function requires the following fields:",
      fields_vector[!fields_vector %in% names(df)],
      "which are missing from your data frame."
      )
  )
}



#' @title force_string_breaks
#' 
#' @description a text processing function to insert a \\n break every x characters
#' 
#' @param string the string
#' @param n_char break every x

force_string_breaks <- function(string, n_char) {
  breaks <- gsub(paste0('(.{1,', n_char, '})(\\s|$)'), '\\1\n', string)  
  #remove trailing and return
  stringr::str_sub(breaks, 1, -2)
}



#' @title ensure_rows_in_df
#' 
#' @description a contract that verifies that a data set isn't length zero
#' 
#' @param . dot-placeholder, per ensurer doc.

ensure_rows_in_df <- ensurer::ensures_that(
  nrow(.) > 0 ~ "Sorry, can't plot that: a data prep step returned a df of 0 rows."
)


#' @title ensure_nonzero_students_with_norms
#' 
#' @description a contract that verifies that a growth df has at least one student with
#' normative data
#' 
#' @param . dot-placeholder, per ensurer doc.

ensure_nonzero_students_with_norms <- ensurer::ensures_that(
  nrow(
    subset(., !is.na(typical_growth))
  ) > 0 ~ paste0("Sorry, can't plot that: None of the students in your selection have",
    " typical growth norms (possibly because they are too old or young and outside",
    " the NWEA norm study)")
)



#' @title numeric_nwea_seasons
#'
#' @description
#' tranforms fall, winter, spring into a numeric offset so things sort the right way
#'
#' @param x a vector of seasons
#' 
#' @return a vector of numeric offsets
#' @export


numeric_nwea_seasons <- function(x) {
  #make the df
  offsets <- data.frame(
    'fallwinterspring' = c('Fall', 'Winter', 'Spring'),
    'season_offset' = c(0.01, 0.02, 0.03),
    stringsAsFactors = FALSE
  )
  
  x_joined <- dplyr::left_join(
    x = data.frame('fallwinterspring' = x, stringsAsFactors = FALSE),
    y = offsets,
    by = 'fallwinterspring'
  ) %>% as.data.frame()
  
  return(x_joined[, 'season_offset', drop = TRUE])
}


#' peek
#'
#' @param df a data frame
#'
#' @return just the head of the data frame, all columns visible
#' @export

peek <- function(df) {
  df %>% head() %>% as.data.frame(stringsAsFactors = FALSE)
}