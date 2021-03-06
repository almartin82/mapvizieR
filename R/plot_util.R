#' @title h_var
#' 
#' @description utility function to make a text grob of desired size
#' 
#' @param text text you want on the grob
#' @param size font size
#' @param gp graphics paramaters.
#' 
#' @export

h_var <- function(text, size, gp=grid::gpar(fontsize=size, fontface = 'bold')) {
  grid::textGrob(
    label = text,
    just = c('left', 'center'),
    x = 0,
    gp = gp
  )
}


#' @title grob_justifier
#' 
#' @description a great little function that baptiste wrote up on my SO queston: 
#' http://stackoverflow.com/a/25456672/561698
#' 
#' @param x a grob
#' @param hjust left, center, or right
#' @param vjust top, center, or bottom 

grob_justifier <- function(x, hjust="center", vjust="center"){
  w <- grid::grobWidth(x)
  h <- grid::grobHeight(x)
  xj <- switch(hjust,
               center = 0.5,
               left = 0.5 * w,
               right=grid::unit(1,"npc") - 0.5 * w)
  yj <- switch(vjust,
               center = 0.5,
               bottom = 0.5*h,
               top=grid::unit(1,"npc") - 0.5 * h)
  x$vp <- grid::viewport(x=xj, y=yj)
  
  #return
  gridExtra::arrangeGrob(x)
}


#' Adds a simple footer to a report page at 1/20th the height of the existing
#' content
#'
#' @param page probably the output of gridExtra::arrangeGrob
#' @param footer_content what you want the footer to say
#'
#' @return a grob with the footer content
#' @export

report_footer <- function(page, footer_content) {
  
  footer <- h_var(footer_content, 10)
  
  out <- arrangeGrob(page, footer, nrow = 2, heights = c(19, 1))
  
  return(out)
}