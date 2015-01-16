#' @title report_dispatcher
#'
#' @description
#' \code{report_dispatcher} munges test term data on a CDF
#'
#' @param roster a roster dataframe.  must have a field called studentid
#' @param cut_list a list of 'org units' in your roster, in order from most general
#' to most specific.  
#' @param call_list a list of booleans.  must be the same length as cut_list.  indicates if
#' the function should get called at cut_list[i]
#' @param func_to_call function that will get passed to do.call
#' @param arg_list arguments to pass to do.call.  \code{report_dispatcher} will inject 
#' \code{studentids, depth_string} into the arg list, as well as named elements 
#' corresponding to the key/value cut and element outlined above
#' @param calling_env defaults to parent frame.
#' 
#' @return a cdf with new term fields 

report_dispatcher <- function(roster, cut_list, call_list, 
    func_to_call, arg_list, calling_env = parent.frame(), ...
  ) {
  require(assertthat)
  require(stringr)
  
  #all of the cuts provided need to match columns in the roster.
  cuts_unlisted <- unlist(cut_list)
  assert_that(all(has_name(roster, cuts_unlisted)))

  #find the unique pairs
  cols <- unlist(cut_list)
  
  #empty data structures
  pairs_vector <- vector(mode='character', length=nrow(roster))
  pairs_df <- data.frame(
    foo=rep(NA, nrow(roster))
  )
  counter <- 1
  
  #todo - test data frame for text to make sure sep is unq
  hash_sep <- '@@@'
  
  #populate data structure to facilitate  unique pairs
  for (c in cols) {
    pairs_vector <- paste(pairs_vector, roster[,c], sep=hash_sep)  
    
    pairs_df[,counter] <- roster[,c]
    names(pairs_df)[counter] <- c
    
    counter <- counter + 1    
  }
  
  #trim leading hash_sep
  pairs_vector <- substr(pairs_vector, 4, 1000000)
  
  #put has back on the larger df
  pairs_df$hash <- pairs_vector

  #get unique keys
  unq_keys <- unique(pairs_vector)
  
  #strsplit on the sep_hash gets us back to data frame
  unq_ele <- do.call(rbind,strsplit(unq_keys, hash_sep, fixed=T))
  #back to df and sort
  unq_ele <- as.data.frame(unq_ele, stringsAsFactors=F)
  names(unq_ele) <- cols  
  #nifty little sort function
  unq_ele <- df_sorter(unq_ele, by=names(unq_ele))  
  #print(unq_ele)    
  
  perm_list <- list()
  counter <- 1
  
  #now get the permutations at each depth
  for (i in 1:length(cols)) {
    
    this_headers <- cols[1:i]
    
    mask <- names(unq_ele) %in% this_headers
    
    #grab the unique permutations at this depth level as data frame
    this_perms <- as.data.frame(unique(unq_ele[,mask]))
    names(this_perms) <- this_headers

    #if we should call the report at this level, add it to the perm_list
    if (call_list[[i]]) {
            
      perm_list[[counter]] <- this_perms
      counter <- counter + 1
      
    #end call test conditional
    }
  #end make perm list loop  
  }
  print(perm_list)

  #iterate over the perm list
  #these are the reports we need to generate
  final_list <- list()
  counter <- 1

  for (i in 1:length(perm_list)) {
    print(i)
    this_depth <- perm_list[[i]]
    
    for (j in 1:nrow(this_depth)) {
      print(j)
      
      this_perm <- this_depth[j,] 
      
      #generic names for depth of tree
      generic_perm <- this_perm
      names(generic_perm) <- paste0('depth_', seq(1:ncol(this_perm)))

      #friendly name string of this depth:
      depth_string <- paste(names(this_perm), this_perm[1,], sep=": ")
      depth_string <- paste(depth_string, collapse=" | ")
            
      #get the matching kids
      studentids <- unique(merge(roster, this_perm))$studentid
      
      #create a local arg list that includes the current perm context
      this_arg_list <- append(arg_list, as.list(this_perm))
      this_arg_list <- append(this_arg_list, list(studentids=studentids))
      this_arg_list <- append(this_arg_list, unlist(this_perm))
      this_arg_list <- append(this_arg_list, unlist(generic_perm))
      this_arg_list <- append(this_arg_list, list(depth_string=depth_string))
      
      #get the names of the function to call
      func_names <- names(formals(func_to_call))
      #drop the arguments that aren't used by the function
      if (! "..." %in% func_names) {
        mask <- names(this_arg_list) %in% func_names
        this_arg_list <- this_arg_list[mask]
      } 
      
      #now that we have the studentids and arg list, call the function
            
      this_output <- do.call(
        what=func_to_call
       ,args=this_arg_list
       ,envir=calling_env
      )
      
      final_list[[counter]] <- this_output
      
      counter <- counter + 1
    #end call elements of perm list loop
    }
  
  #end perm list
  }
  
  return(final_list)

#end function
}
