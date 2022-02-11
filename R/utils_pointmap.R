#' Functions to make a map of population points that are in the dataset, which can be filtered by selected taxonomic group.
#'
#' @param target_taxa 
#'
#' @return Leaflet map of point coordinations for populations included in the dataset.
#' @export
#'

# function to make empty map 
make_pointmap <- function(){
  mapselector::make_leaflet_empty() 
}

# function to filter the dataset to selected taxa
filter_atlas <- function(target_taxa){

  # get time series and taxonomic info to observations
  obs <- dplyr::left_join(ratlas::get_timeseries(), 
                   ratlas::get_gen(endpoint="taxa"), 
                   by = c("id_taxa" = "id"))
  obs$id <- as.character(obs$id)
  
  # check that the input makes sense
  stopifnot(target_taxa %in% c("Poissons", "Amphibiens", "Oiseaux", "Mammifères", "Reptiles", "Tous"))
  
  # Subset to selected taxa 
  if (target_taxa != "Tous") {
    obs <- subset(obs, obs$species_gr == target_taxa)
  } 
  return(obs)
}

# show map points from filtered dataset
filter_leaflet_map <- function(mapid, taxa_to_show = "Tous"){
  
  # create icons for the populations
  ics <- make_site_icons()
  
  obs <- filter_atlas(taxa_to_show)
  # pull out coordinates to make them recognizable to leaflet
  coord <- head(t(sapply(obs$geom$coordinates, as.list)), nrow(obs))
  colnames(coord) <- c("lng", "lat")
                       
  leaflet::leafletProxy(mapid) %>%
    leaflet::clearMarkers() %>% 
    leaflet::addAwesomeMarkers(
      data = obs,
      icon = ~ics[obs$species_gr],
      lng = as.numeric(coord[, "lng"]), 
      lat = as.numeric(coord[, "lat"]),
      layerId = obs[["id"]],
      label = obs[["scientific_name"]]
    )
}