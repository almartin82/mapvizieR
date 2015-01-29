#' @title fuzz_test_plot
#' 
#' @description throws a random subset of students against a plot n times, and reports back
#' if a valid ggplot gets returned
#' 
#' @param plot_name name of a plot, as text.  gets thrown to do call
#' @param n how many times to test?
#' @param additional_args all plots will get "mapvizieR_obj" and "studentids".  if your
#' plot needs additional args, pass them here.

fuzz_test_plot <- function(plot_name, n=100, additional_args=list()) {
  
  mapviz <- mapvizieR(
    raw_cdf=ex_CombinedAssessmentResults, 
    raw_roster=ex_CombinedStudentsBySchool
  )

  results <- vector("list", n)
  
  for (i in seq(1:n)) {
    stu_random <- sample(mapviz[['roster']]$studentid, sample(20:500, 1)) %>% 
      unique 
    
    arg_list <- list(
      "mapvizieR_obj"=mapviz
     ,"studentids"=stu_random
    )
    
    arg_list <- c(arg_list, additional_args)

    p <- do.call(
      what=plot_name, 
      args=arg_list
    )
    
    tests <- all(
      is.ggplot(p)
     ,all(
        c("data", "layers", "scales", "mapping", "theme", 
          "coordinates", "facet", "plot_env", "labels") %in% names(p)
      )
    )
    
    results[[i]] <- tests
  }
  
  return(results)  
}



#' @title silly plot
#' 
#' @description just a dead simple plot that we can use to test the fuzz_test function
#' 
#' @param mapvizieR_obj a conforming mapvizieR object
#' @param studentids a vector of studentids

silly_plot <- function(mapvizieR_obj, studentids) {
  p <- ggplot(
    data=mapvizieR_obj[['cdf']]
   ,aes(x=testritscore)
  ) + 
  geom_histogram()
  
  return(p)
}