#' @title report_dispatcher
#'
#' @description
#' \code{report_dispatcher} applies a mapvizieR over the unique 'org units' in a roster object.
#'
#' @param mapvizieR_obj a conforming mapvizieR object.
#' @param cut_list a list of 'org units' in your roster, in order from most general
#' to most specific.  
#' @param call_list a list of booleans.  must be the same length as cut_list.  indicates if
#' the function should get called at cut_list[i]
#' @param func_to_call function that will get passed to do.call
#' @param arg_list arguments to pass to do.call.  \code{report_dispatcher} will inject 
#' \code{studentids, depth_string} into the arg list, as well as named elements 
#' corresponding to the key/value cut and element outlined above
#' @param calling_env defaults to parent frame.
#' @param post_process a post processing function to apply to the list of plots we get back.
#' default behavior is only_valid_plots(), which drops any plot that failed.  
#' don't want that?  write something new :)
#' @param verbose should the function print updates about what is happening?  default is TRUE.
#' @param ... other parameters to pass through (namely cdfs).  todo: reformat this function
#' to take mapvizieR object.
#' 
#' @export
#' 
#' @return a list of output from the function you called

report_dispatcher <- function(
    mapvizieR_obj,
    cut_list, 
    call_list, 
    func_to_call, 
    arg_list=list(),
    calling_env = parent.frame(),
    post_process = "only_valid_plots",
    verbose = TRUE,
    ...
  ) {
  #use ensureR to check if this is a mapvizieR object
  mapvizieR_obj %>% ensure_is_mapvizieR()
  roster <- mapvizieR_obj[['roster']]
  
  #put mapvizieR object onto the arg list
  arg_list <- append(arg_list, list(mapvizieR_obj = mapvizieR_obj))
  
  #all of the cuts provided need to match columns in the roster.
  cuts_unlisted <- unlist(cut_list)
  assertthat::assert_that(all(assertthat::has_name(roster, cuts_unlisted)))

  #find the unique pairs
  cols <- unlist(cut_list)
  pairs_roster <- roster[ , names(roster) %in% cols, drop = FALSE]
  unq_ele <- unique(pairs_roster)
  #nifty little sort function
  unq_ele <- df_sorter(unq_ele, by = names(unq_ele))   
  
  perm_list <- list()
  counter <- 1
  
  #set names of each cut to 'All' so that sbugroups can be referenced before 
  for (cut in cut_list) {
    assign(cut, 'All')
  }
    
  
  #now get the permutations at each depth
  for (i in 1:length(cols)) {
    
    #if we should call the report at this level, add it to the perm_list
    if (call_list[[i]]) {
    
      this_headers <- cols[1:i]
      
      mask <- names(unq_ele) %in% this_headers
      
      #grab the unique permutations at this depth level as data frame
      perm_list[[counter]] <- as.data.frame(unique(unq_ele[, mask, drop = FALSE]))
      counter <- counter + 1
      
    #end call test conditional
    }
  #end make perm list loop  
  }
  
  if (verbose) {writeLines('permutations on selected cuts are:'); print(perm_list)}

  #iterate over the perm list
  #these are the reports we need to generate
  output_list <- list()
  counter <- 1

  for (i in 1:length(perm_list)) {
    this_depth <- as.data.frame(perm_list[[i]], drop = FALSE)
    
    for (j in 1:nrow(this_depth)) {
      this_perm <- this_depth[j, ,drop = FALSE]

      rd_env <- new.env()
      
      #generic names for depth of tree
      generic_perm <- this_perm
      names(generic_perm) <- paste0('depth_', seq(1:ncol(this_perm)))

      #friendly name string of this depth:
      rd_env$depth_string <- paste(names(this_perm), this_perm[1,], sep = ": ")
      rd_env$depth_string <- paste(rd_env$depth_string, collapse = " | ")
      if (verbose) print(rd_env$depth_string)
      
      #get the matching kids
      studentids <- unique(merge(roster, this_perm))$studentid
      
      #create a local arg list that includes the current perm context
      this_arg_list <- append(arg_list, as.list(this_perm))
      this_arg_list <- append(this_arg_list, list(studentids = studentids))
      this_arg_list <- append(this_arg_list, unlist(this_perm))
      this_arg_list <- append(this_arg_list, unlist(generic_perm))
      this_arg_list <- append(this_arg_list, list(depth_string = rd_env$depth_string))
      
      #inject all the args into the rd_env
      list2env(x = this_arg_list, envir = rd_env)
      
      #get the names of the function to call
      func_names <- names(formals(func_to_call))
      #drop the arguments that aren't used by the function
      if (!"..." %in% func_names) {
        mask <- names(this_arg_list) %in% func_names
        this_arg_list <- this_arg_list[mask]
      } 
      
      #now that we have the studentids and arg list, call the function      
      this_output <- try(
        do.call(
          what = func_to_call,
          args = this_arg_list,
          envir = rd_env
        )
      )
      
      output_list[[counter]] <- this_output
      names(output_list)[[counter]] <- rd_env$depth_string
      counter <- counter + 1
    #end call elements of perm list loop
    }
  #end perm list
  }
  
  #apply post-processing function
  final_list <- do.call(what = post_process, args = list(x = output_list))
  
  return(final_list)

#end function
}



#' @title only_valid_plots
#' 
#' @description a post-processor for report_dispatcher
#' 
#' @param x a list of report_dispatcher output

only_valid_plots <- function(x) {
  mask <- sapply(x, is_not_error) 
  x[mask]
}