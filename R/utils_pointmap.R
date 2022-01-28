#' Functions to make a map of population points that are in the dataset, which can be filtered by selected taxonomic group.
#'
#' @param target_taxa 
#'
#' @return Leaflet map of point coordinations for populations included in the dataset.
#' @export
#'

## colour palette ##
pal <- c("Amphibiens" = "#56B4E9",
         "Mammifères" = "#D55E00", 
         "Oiseaux" = "#E69F00", 
         "Poissons" = "#0072B2", 
         "Reptiles" = "#009E73",
         "#999999")


# function to make empty map with legend
make_pointmap <- function(){

  ## MAP ##
  mapselector::make_leaflet_empty()  %>%
    leaflet::addLegend(
      "topleft",
      colors = pal[c(1:5)],
      labels = c("Amphibiens", "Mammifères", "Oiseaux", "Poissons", "Reptiles"),
      opacity = 1
    )
}


# function to filter the dataset to selected taxa
filter_atlas <- function(target_taxa){

  # get time series and taxonomic info to observations
  obs <- dplyr::left_join(ratlas::get_timeseries(), 
                   ratlas::get_gen(endpoint="taxa"), 
                   by = c("id_taxa" = "id"))
  obs$id <- as.character(obs$id)
  
  stopifnot(target_taxa %in% c("Poissons", "Amphibiens", "Oiseaux", "Mammifères", "Reptiles", "Tous"))
  
  # Subset to selected taxa 
  if (target_taxa != "Tous") {
    obs <- subset(obs, obs$species_gr == target_taxa)
  } 
  return(obs)
}

## function to set marker color ##
getColor <- function(obs) {
  pal[obs$species_gr]
}


## POP-UPS when clicking a map point ##
get_popup_content <- function(obs){
  paste0(
    #"<b>", obs$common_name, "</b>", # to replace when this info is in the taxa table
    "<br><i>", gsub("_", " ", obs$scientific_name), "</i>",
    "<br>", obs$species_gr#, 
    #"<br><b>Source: </b>", obs$intellectual_rights
  )
}

# show map points from filtered dataset
filter_leaflet_map <- function(mapid, taxa_to_show = "Tous"){
  
  obs <- filter_atlas(taxa_to_show)
  
  # pull out coordinates to make them recognizable to leaflet
  coord <- head(t(sapply(obs$geom$coordinates, as.list)), nrow(obs))
  colnames(coord) <- c("lng", "lat")
                       
  leaflet::leafletProxy(mapid) %>%
    leaflet::clearMarkers() %>% 
    leaflet::addCircleMarkers(
      data = obs,
      lng = as.numeric(coord[, "lng"]), 
      lat = as.numeric(coord[, "lat"]),
      layerId = obs[["id"]],
      label = obs[["id"]],
      #popup = ~get_popup_content(obs),
      color = unname(getColor(obs)),
      stroke = FALSE,
      fillOpacity = .7,
      radius = 5
    )
}