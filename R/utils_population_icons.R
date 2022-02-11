#' population_icons 
#'
#' @description A utils function
#'
#' @return The return value, if any, from executing the utility.
#'
#' @noRd
#' @export
#' 
icon_colours <- function(){
  icon_options <- list(
    "Amphibiens" = list(ico = '<i class="fianimals animals-010-frog"></i>', col = "green"),
    "Mammifères" = list(ico = '<i class="fianimals animals-015-squirrel"></i>', col = "darkred"),
    "Oiseaux" = list(ico = '<i class="fianimals animals-020-bird"></i>', col = "orange"),
    "Poissons" = list(ico = '<i class="finature-collection nature-collection-fish" ></i>', col = "blue"),
    "Reptiles" = list(ico = '<i class="fianimals animals-038-turtle"></i>', col = "darkgreen")
  )
  
  return(icon_options)
}  


#' @export
make_site_icons <- function() {
  
  icon_options <- lapply(X = icon_colours(), 
                         function(l) list(
                           text =  l$ico,
                           markerColor = l$col
                         ))
  
  awesome_icon_list <- lapply(icon_options, do.call, what = leaflet::makeAwesomeIcon)
  
  site_icons <- do.call(leaflet::awesomeIconList, awesome_icon_list)
  
  return(site_icons)
}