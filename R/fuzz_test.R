#' @title fuzz_test_plot
#'
#' @description throws a random subset of students against a plot n times, and reports back
#' if a valid ggplot gets returned
#'
#' @param plot_name name of a plot, as text.  gets thrown to do call
#' @param n how many times to test?
#' @param additional_args all plots will get "mapvizieR_obj" and "studentids".  if your
#' plot needs additional args, pass them here.
#' @param mapviz a \code{\link{mapvizieR}} object.

fuzz_test_plot <- function(
  plot_name,
  n = 100,
  additional_args = list(),
  mapviz = mapvizieR(
    cdf = ex_CombinedAssessmentResults,
    roster = ex_CombinedStudentsBySchool
  )
) {

  results <- vector("list", n)
  studentids <- vector("list", n)

  sample_limit <- ifelse(
    length(mapviz[['roster']]$studentid) < 500, length(mapviz[['roster']]$studentid), 500
  )

  for (i in seq(1:n)) {
    stu_random <- sample(mapviz[['roster']]$studentid, sample(20:sample_limit, 1)) %>%
      unique

    arg_list <- list(
      "mapvizieR_obj" = mapviz
     ,"studentids" = stu_random
    )

    arg_list <- c(arg_list, additional_args)

    p <- try(
      do.call(
        what = plot_name,
        args = arg_list
      ),
      silent = TRUE
    )

    known_error <- try(stringr::str_detect(p, 
                                           stringr::fixed("Sorry, can't plot that")
                                           ), 
                       silent = TRUE)

    if(known_error == TRUE) {
      #known errors are passed tests
      results[[i]] <- known_error
      studentids[[i]] <- stu_random
      next
    }

    build_p <- try(ggplot_build(p))

    tests <- all(
      is.list(build_p)
     ,all(
        c("data", "panel", "plot") %in% names(build_p)
      )
    )

    #append
    results[[i]] <- tests

    #always put the studentids on the list
    studentids[[i]] <- stu_random
  }

  #if a test fails, print the results
  if (!(all(unlist(results)))) {

    writeLines(paste('fuzz testing', plot_name, 'failed!'))
    writeLines(paste('outputting studentid vectors that caused', plot_name, 'to fail:'))

    failed_on <- studentids[c(results == FALSE)] %>%
      paste(collapse = '\n\n\n') %>%
      strwrap()

    writeLines(failed_on)

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
  mapvizieR_obj %>% ensure_is_mapvizieR()

  p <- ggplot(
    data = mapvizieR_obj[['cdf']]
   ,aes(x = testritscore)
  ) +
  geom_histogram()

  return(p)
}



#' @title error ridden plot
#'
#' @description a plot that is definitely going to break
#'
#' @param mapvizieR_obj a conforming mapvizieR object
#' @param studentids a vector of studentids

error_ridden_plot <- function(mapvizieR_obj, studentids) {
  cdf <- mapvizieR_obj[['cdf']]
  cdf <- cdf[cdf$studentid == 'pancakes', ]

  p <- ggplot(
    data = cdf
   ,aes(x = testritscore)
  ) +
  geom_histogram()

  return(p)
}
