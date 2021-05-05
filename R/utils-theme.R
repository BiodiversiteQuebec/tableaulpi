#' Mapselector ggplot2 theme
#'
#' @return A \code{ggplot} theme that can be added to any \code{ggplot} object to change its theme. Plot titles are set to be larger, grid lines are adjusted to show only major grid lines, and facet colours and label size are set.
#' @export
#'
#' @examples 
#' library(ggplot2)
#' ggplot(diamonds) + 
#' geom_point(aes(x = carat, y = price, col = color)) + 
#' theme_mapselector()

theme_mapselector <- function(){
  
  font <- "Helvetica"
  
  ggplot2::theme(
    
    # Plot title
    plot.title = ggplot2::element_text(
      family = font, 
      size = 16, 
      face = "bold", 
      color = "#222222"), 
    
    # Plot subtitle
    plot.subtitle = ggplot2::element_text(
      family = font, 
      size = 14, 
      margin = ggplot2::margin(9, 0, 9, 0)), 
    
    # Plot caption
    plot.caption = ggplot2::element_text(
      family = font,
      size = 12,
      color = "#222222"),
    
    # Legend
    legend.position = "right", 
    legend.text.align = 0, 
    legend.background = ggplot2::element_blank(), 
    legend.key = ggplot2::element_blank(), 
    legend.text = ggplot2::element_text(
      family = font, 
      size = 14, 
      color = "#222222"), 
    legend.title = ggplot2::element_text(
      family = font, 
      size = 14, 
      face = "bold"),
    
    # Axes
    axis.text = ggplot2::element_text(family = font, 
                                      size = 14, 
                                      color = "#222222"), 
    axis.title = ggplot2::element_text(family = font, 
                                      size = 18, 
                                      face = "bold",
                                      color = "#222222"),              
    
    # Panel grid lines
    panel.grid.minor = ggplot2::element_blank(), 
    panel.grid.major = ggplot2::element_line(color = "#e6e6e6"), 
    panel.background = ggplot2::element_blank(), 
    
    # Facets            
    strip.background = ggplot2::element_rect(fill = "white"), 
    strip.text = ggplot2::element_text(size = 12, hjust = 0)
    )
}
