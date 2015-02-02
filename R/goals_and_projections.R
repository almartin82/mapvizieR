# This is the structure of the goals object.
# studentid
# measurementscale
# grade_level_season
# growth_season
# simulation_number (this is for any simulated results so we can show projected uncertainty. See the map_projector concept).
# projected RIT Score.
# projected RIT Score type (i.e., typical or accelerated).
# pointer to testid?
# 
# persistence of "projects"/goals?
# 
# hold object as promise? Does this hurt architecture that generates goals and then adds them back to object.


#I think we can have mulitple goals objects.  One for typical goals
# one ofr Accelerated goals as calcled with KIPP Tiered
# one to n for custome goals 

# create data.frame suitable for saving to a 
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
                  start_testid, 
                  end_testid,
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
    join_by_fields=c("studentid", "start_testid", "end_testid"),
    slot_name = "kipp_tiered_goals"
  )
}    


add_accelerated_growth <- function(mapvizier_object, 
                         goal_function=goal_kipp_tiered, 
                         goal_function_args=list(iterations=1),
                         updated_growth_df=FALSE){
    # this should be run in the mapvizier method after the mapvizier class
    # is assigned.  That way it can be used in the constructor method or
    # outside of it for adding new growth to the 
   
   
   goal_function_args$mapvizier_object<-ensure_is_mapvizieR(mapvizier_object)
   
   goals_obj<-do.call(goal_function, goal_function_args) %>%
     ensure_goals_obj
   
   #
   mapvizier_object$goals[[goals_obj$slot_name]]<-goals_obj
   
   if(updated_growth_df){
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
         select(accel_growth=accel_growth.x,
                met_accel_growth=met_accel_growth.x,
                -accel_growth.y,
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
ensure_goals_obj<- ensures_that(+ensure_goals_names,
  all(
    c("accel_growth",  "met_accel_growth") %in% names(.$goals)) ~
              paste0("Your goals function's goals data frame ", "
                     must have accel_growth and met_accel_growth fields.")
    )

ensure_goals_names<-ensures_that(
  all(
    c("goals", "join_by_fields", "slot_name") %in% 
      names(.)) ~ 
    paste0("Your goals function must create a list ", 
                      "with slots for 'goals', 'join_by_fields', ",  
                      "and 'slot_name'.")
  )



