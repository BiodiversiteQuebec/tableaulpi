# Function to make a point map of populations included in the Living Planet Index

#' @import dplyr

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


filter_lpd_qc <- function(target_taxa){
  ## SELECTION ##
  lpd_qc <- readRDS("data/lpd_qc_fake.RDS")
  #tableaulpi::lpd_qc_fake
  
  stopifnot(target_taxa %in% c("poissons",
                               "mammifères", 
                               "reptiles", 
                               "amphibiens", 
                               "oiseaux","tous"
  ))
  
  
  if (target_taxa != "tous") {
    lpd_qc_filtered <- subset(lpd_qc, lpd_qc$taxa == target_taxa)
  } else {
    lpd_qc_filtered <- lpd_qc
  }
  return(lpd_qc_filtered)
}

pal <- c("amphibiens" = "#56B4E9",
         "mammifères" = "#D55E00", 
         "oiseaux" = "#E69F00", 
         "poissons" = "#0072B2", 
         "reptiles" = "#009E73",
         "#999999")

## function to set marker color ##
getColor <- function(data_with_taxa_names) {
  pal[data_with_taxa_names$taxa]
}


## POP-UPS ##
get_popup_content <- function(lpd_qc_dataset){
  paste0(
    "<b>", lpd_qc_dataset$common_name, "</b>",
    "<br><i>", gsub("_", " ", lpd_qc_dataset$scientific_name), "</i>",
    "<br><b>Source: </b>", lpd_qc_dataset$intellectual_rights
  )
}

filter_leaflet_map <- function(mapid, taxa_to_show = "tous"){
  
  lpd_qc_filtered <- filter_lpd_qc(taxa_to_show)
  
  leaflet::leafletProxy(mapid) %>%
    leaflet::clearMarkers() %>% 
    leaflet::addCircleMarkers(
      data = lpd_qc_filtered,
      layerId = lpd_qc_filtered[["org_event"]],
      label = lpd_qc_filtered[["org_event"]],
      popup = ~get_popup_content(lpd_qc_filtered),
      color = unname(getColor(lpd_qc_filtered)),
      stroke = FALSE,
      fillOpacity = .7,
      radius = 5
    )
}
