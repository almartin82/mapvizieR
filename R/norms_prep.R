#' @title norms_students_wide_to_long
#' 
#' @description takes the wide norms_students object and makes it long
#' 
#' @param norms a norms_student object.  defaults to norms_students_2011
#' 

norms_students_wide_to_long <- function(norms=norms_students_2011) {
  names(norms) <- tolower(names(norms))
  
  #1,2,3,4 
  #1=winter, 2=spring, 3=summer, 4=fall
  
  f2w <- norms[ , c('measurementscale', 'startgrade', 'startrit', 't41', 'r41', 's41')]
  f2s <- norms[ , c('measurementscale', 'startgrade', 'startrit', 't42', 'r42', 's42')]
  f2f <- norms[ , c('measurementscale', 'startgrade', 'startrit', 't44', 'r44', 's44')]
  s2s <- norms[ , c('measurementscale', 'startgrade', 'startrit', 't22', 'r22', 's22')]
  w2s <- norms[ , c('measurementscale', 'startgrade', 'startrit', 't12', 'r12', 's12')]

  f2w$growth_window <- 'Fall to Winter'
  f2s$growth_window <- 'Fall to Spring'
  f2f$growth_window <- 'Fall to Fall'
  s2s$growth_window <- 'Spring to Spring'
  w2s$growth_window <- 'Winter to Spring'
  
  #rename
  standardized_names <- c(
    'measurementscale', 'startgrade', 'startrit', 'typical_growth', 
    'reported_growth', 'std_dev_of_expectation', 'growth_window'
  )
  names(f2w) <- standardized_names
  names(f2s) <- standardized_names
  names(f2f) <- standardized_names
  names(s2s) <- standardized_names
  names(w2s) <- standardized_names
  
  #rbind, reorder and return
  norms_long <- rbind(f2w, f2s, f2f, s2s, w2s)
  norms_long <- norms_long[ , c(1:3,7,4:6)]
  
  return(norms_long)
}