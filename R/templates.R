#' template 1 
#' 
#' @description (1 x 1) columns
#'
#' @param p01 plot or grob
#' @param p02 plot or grob
#'
#' @return grob, output of arrangeGrob
#' @export

template_01 <- function(p01, p02) {
  grid::grid.newpage()
  
  gridExtra::arrangeGrob(
    p01 %>% tg(), p02 %>% tg(), ncol = 2    
  )
}
  

#' template 2 
#' 
#' @description (1 x 1 x 1)
#'
#' @param p01 plot or grob
#' @param p02 plot or grob
#' @param p03 plot or grob
#'
#' @return grob, output of arrangeGrob
#' @export

template_02 <- function(p01, p02, p03) {
  grid::grid.newpage()
  
  gridExtra::arrangeGrob(
    p01 %>% tg(), p02 %>% tg(), p03 %>% tg(), ncol = 3    
  )
}


#' template 3
#' 
#' @description row 1: (1 x 1), row 2 (1 x 1)
#'
#' @param p01 plot or grob
#' @param p02 plot or grob
#' @param p03 plot or grob
#' @param p04 plot or grob
#'
#' @return grob, output of arrangeGrob
#' @export

template_03 <- function(p01, p02, p03, p04) {
  grid::grid.newpage()
  
  arrangeGrob(
    grobs = list(p01 %>% tg(), p02 %>% tg(), p03 %>% tg(), p04 %>% tg()), 
    layout_matrix = rbind(c(1, 2), c(3, 4))
  )
}


#' template 4 
#' 
#' @description col 1: (1 x 1), col 2: 1, col 3: (1 x 1)
#'
#' @param p01 plot or grob
#' @param p02 plot or grob
#' @param p03 plot or grob
#' @param p04 plot or grob
#' @param p05 plot or grob
#'
#' @return grob, output of arrangeGrob
#' @export

template_04 <- function(p01, p02, p03, p04, p05) {
  grid::grid.newpage()
  
  arrangeGrob(
    grobs = list(
      p01 %>% tg(), p02 %>% tg(), p03 %>% tg(), p04 %>% tg(), p05 %>% tg()
    ), 
    layout_matrix = cbind(c(1, 2), c(3, 3), c(4, 5)),
    ncol = 3, widths = c(1, 2, 1)
  )
}


#' tg "to grob" helper function
#'
#' @param x a report object. currently supports grobs or ggplot objects
#'
#' @return a grob, suitable for arrangeGrob on a report layout

tg <- function(x) {

  if ('ggplot' %in% class(x)) {
    x <- ggplotGrob(x)
  }
  
  x
}


#' template 5 
#' 
#' @description (1 x 1), rows
#'
#' @param p01 plot or grob
#' @param p02 plot or grob
#'
#' @return grob, output of arrangeGrob
#' @export

template_05 <- function(p01, p02) {
  grid::grid.newpage()
  
  gridExtra::arrangeGrob(
    p01 %>% tg(), p02 %>% tg(), nrow = 2    
  )
}



#' template 6
#' 
#' @description col 1: (1 x 1), col 2: 1, col 3: (1 x 1)
#'
#' @param p01 plot or grob
#' @param p02 plot or grob
#' @param p03 plot or grob
#' @param p04 plot or grob
#' @param p05 plot or grob
#'
#' @return grob, output of arrangeGrob
#' @export

template_06 <- function(p01, p02, p03, p04, p05) {
  grid.newpage()
  
  arrangeGrob(
    grobs = list(
      p01 %>% tg(), p02 %>% tg(), p03 %>% tg(), p04 %>% tg(), p05 %>% tg()
    ), 
    layout_matrix = cbind(
      c(1, 2, 2, 2, 2, 2, 2, 2, 2), 
      c(3, 3, 3, 4, 4, 4, 5, 5, 5)),
    ncol = 2, widths = c(2, 1)
  )
}