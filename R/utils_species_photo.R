#' Get species photo from iNaturalist
#' 
#' Gets a photo for a selected population's species name from iNaturalist. This function can then be used within the \code{summarise_rawdata} module to generate the species photo on the dashboard in reaction to a click.
#'
#' @param clicked_population Population selected from a user's click on the point map.
#' 
#' @return A photo of the selected population's species.
#' @export

make_species_photo <- function(clicked_population){
  
  # get data for the clicked population
  obs <- ratlas::get_timeseries() 
  obs <- obs %>%
    dplyr::filter(id == as.integer(clicked_population)) %>%
    dplyr::left_join(., 
                     ratlas::get_gen(endpoint="taxa",
                                        id = unique(obs$id_taxa)),
                     by = c("id_taxa" = "id"))
    
  
  src <- mapselector::get_species_photo(obs$scientific_name[1])$thumb_url
  
  return(tags$img(src=src, height="200", width ="200")) # how to control the size of the photo here? sometimes it's still huge
}