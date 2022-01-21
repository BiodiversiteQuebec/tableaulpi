#' Get species photo from iNaturalist
#' 
#' Gets a photo for a selected population's species name from iNaturalist. This function can then be used within the \code{summarise_rawdata} module to generate the species photo on the dashboard in reaction to a click.
#'
#' @param clicked_population Population selected from a user's click on the point map.
#' 
#' @return A photo of the selected population's species.
#' @export

make_species_photo <- function(clicked_population){
  
  obs <- dplyr::filter(ratlas::get_gen(endpoint="taxa"),  # to update with get_taxa when ready
                       id == as.integer(clicked_population))
  
  src <- mapselector::get_species_photo(obs$scientific_name[1])$thumb_url
  
  return(tags$img(src=src))
}