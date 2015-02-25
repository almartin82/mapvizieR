#' @title Create KIPP Tiered accelerated growth goals
#' 
#' @description
#' \code{goal_kipp_tiered} is a "goal function": it creates a list with three
#' elements: a \code{goals} data frame (including  fields \code{accel_growth} and 
#' \code{met_accel_growth} used in the \code{growth_df} of a \code{\link{mapvizieR}}
#' object. 
#' 
#' @param mapvizier_object a \code{\link{mapvizieR}} object. 
#' @param iterations the number of iterations out from any student test event
#' you wish to continue projecting student growth.  This features is not 
#' yet implemented, so it only projects growth one iteration. 
#' 
#' @examples
#' data(ex_CombinedAssessmentResults)
#' data(ex_CombinedStudentsBySchool)
#' 
#' cdf_mv <- mapvizieR(ex_CombinedAssessmentResults, 
#'                     ex_CombinedStudentsBySchool)
#'                     
#' goals<-goal_kipp_tiered(cdf_mv)                     
#' 
#' @export
goal_kipp_tiered <- function(mapvizier_object, iterations=1){
  
  
  x<-ensure_is_mapvizieR(mapvizier_object)
  growth_df<-x$growth_df 
  if(!"iter" %in% names(growth_df)) growth_df$iter<-0 # add and set iterator
  out<-growth_df %>%
    as.data.frame %>%
    dplyr::select(studentid, 
           measurementscale, 
           start_testid,
           start_grade,
           growth_window,
           start_grade_level_season,
           start_fallwinterspring,
           end_testid,
           end_fallwinterspring,
           start_testritscore,
           start_testpercentile,
           reported_growth,
           rit_growth,
           iter) %>%
    dplyr::mutate(start_testquartile=kipp_quartile(start_testpercentile),
           kipp_tiered_growth=tiered_growth_factors(quartile = start_testquartile, 
                                                    grade=start_grade),
           accel_growth=reported_growth*kipp_tiered_growth,
           met_accel_growth=rit_growth>=accel_growth,
           iter=iter+1) %>%
    dplyr::select(studentid, 
                  measurementscale,
                  start_testid, 
                  end_testid,
                  growth_window,
                  start_fallwinterspring,
                  end_fallwinterspring, 
                  accel_growth, 
                  met_accel_growth, 
                  iter) %>%
    as.data.frame
  
  if(iterations>1){
    while(out$iter<=iterations){
     # to do:
      # add loop to expand iteratsion
      # probaby need a better stopping rule (like max grade_season)
      break
    }
  } 
  # return
  out_list<-list(
    goals=out,
    join_by_fields=c("studentid", 
                     "start_testid", 
                     "end_testid", 
                     "measurementscale",
                     "growth_window"),
    slot_name = "kipp_tiered_goals"
  )
}    

#' @title Add an accelerated growth object, including projections and 
#' simulations, to a mapvizieR object
#' 
#' @description
#' \code{add_accelerated_growth} is a constructor function that adds a 
#' "goals" object (a list with a \code{goals} data frame, a \code{join_by_fields}
#' character vector, and \code{slot_name} single element character vector) to
#' a \code{\link{mapvizieR}} object. The goals object is added to a \code{goals}
#' slot in the \code{mapvizieR} object. The goals themselves, as well as any 
#' projections or simulations, are created by a "goals function" (see \code{\link{goal_kipp_tiered}}
#' for an example) that is passed as the \code{goal_function argument}; 
#' arguments to the \code{goal_function} are passed via the \code{goal_function_args} 
#' argument. Note well that the \code{goal_function} must (i) return a list with 
#' three elements (the goals data frame, the join_by_fields character vector,
#' and the slot_name) and (ii) the goals data frame must have at least fields named
#' \code{accel_growth} and \code{met_accel_growth}. If the \code{updated_growth_df}
#' is TRUE then the goals data frame is \code{inner_join}ed  with the 
#' \code{growth_df} using the \code{join_by_fields}, accelerated growth columns are added or updated, and any 
#' duplicate columns from the join are cleaned up (original columns from 
#' the \code{growth_df} are maintened). Obviouslly, the goals function should
#' return a one to one match on any first iterations. 
#' 
#' @param mapvizier_object a \code{\link{mapvizieR}} object. 
#' @param goal_function a function that returns a list containing a a data 
#' frame named \code{goals}, a character vector of columns used to join 
#' accelerated goals to \code{growth_df}, and \code{slot_name} single element
#' character vector used to name the slot in the \code{goals} element of 
#' a \code{mapvizieR} object. 
#' @param  goal_function_args arguments passed to \code{goal_function}
#' @param update_growth_df if \code{TRUE} accelerated growth and met accelerated
#' growth columns are added/updated in the \code{growth_df} of a \code{mapvizieR}
#' object
#' 
#' @return a \code{\link{mapvizieR}} object. 
#' 
#' @examples
#' data(ex_CombinedAssessmentResults)
#' data(ex_CombinedStudentsBySchool)
#' 
#' cdf_mv <- mapvizieR(ex_CombinedAssessmentResults, 
#'                     ex_CombinedStudentsBySchool)
#'                     
#' new_mv<-add_accelerated_growth(cdf_mv,
#'                                goal_function=goal_kipp_tiered, 
#'                                goal_function_args=list(iterations=1),
#'                                update_growth_df=FALSE)
#' str(new_mv)                                
#' 
#' @export

add_accelerated_growth <- function(mapvizier_object, 
                         goal_function=goal_kipp_tiered, 
                         goal_function_args=list(iterations=1),
                         update_growth_df=FALSE){
    # this should be run in the mapvizier method after the mapvizier class
    # is assigned.  That way it can be used in the constructor method or
    # outside of it for adding new growth to the 
   
   
   goal_function_args$mapvizier_object<-ensure_is_mapvizieR(mapvizier_object)
   
   goals_obj<-do.call(goal_function, goal_function_args) %>%
     ensure_goals_obj
   
   #
   mapvizier_object$goals[[goals_obj$slot_name]]<-goals_obj
   
   if(update_growth_df){
     new_growth_df<-
       mapvizier_object$growth_df %>%
       inner_join(goals_obj$goals,
                 by=goals_obj$join_by_fields)
      
     # clean_up from join
     # set accel.growth.y= accel.growth 
     if("accel_growth.y" %in% names(new_growth_df)) {
       new_growth_df <- new_growth_df %>%
         mutate(accel_growth.x=accel_growth.y,
                met_accel_growth.x=met_accel_growth.y) %>%
         rename(accel_growth=accel_growth.x,
                met_accel_growth=met_accel_growth.x) %>%
         select(-accel_growth.y,
                -met_accel_growth.y) 
     }
       
     #remove .x from names
     names(new_growth_df)<-gsub("\\.x","", names(new_growth_df))
     
     #eliminate .y colums
     return_cols<-
       names(new_growth_df)[!grepl("\\.y",names(new_growth_df))]
     
     new_growth_df <- new_growth_df[,return_cols] %>%
       select(-iter) %>%
       as.data.frame
     
     mapvizier_object$growth_df<-new_growth_df
   }
   
   #return
   mapvizier_object %>% ensure_is_mapvizieR
  }
  
    


# ensures ####
#' @title ensure_goals_names
#' 
#' @description a contract that ensures that a goal object's has the 
#' proper elements. 
#' 
#' @param . dot-placeholder, per ensurer doc.
ensure_goals_names<-ensures_that(
  all(
    c("goals", "join_by_fields", "slot_name") %in% 
      names(.)) ~ 
    paste0("Your goals function must create a list ", 
           "with slots for 'goals', 'join_by_fields', ",  
           "and 'slot_name'.")
)

#' @title ensure_goals_obj
#' 
#' @description a contract that ensures that a goal object's has the proper  
#' elements and that the \code{goals} element data frame has columns names
#' \code{accel_growth} and \code{met_acc}
#' 
#' @param . dot-placeholder, per ensurer doc.
ensure_goals_obj<- ensures_that(+ensure_goals_names,
  all(
    c("accel_growth",  "met_accel_growth") %in% names(.$goals)) ~
              paste0("Your goals function's goals data frame ", "
                     must have accel_growth and met_accel_growth fields.")
    )






