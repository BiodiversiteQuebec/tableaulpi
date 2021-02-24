# Function to make a point map of populations included in the Living Planet Index

#' @import dplyr

make_pointmap <- function(taxa){
  
  # Import sf object of points in the Living Planet Database
  lpd_qc <- tableaulpi::lpd_qc_fake

  ## PALETTE ##
  
  # create colorblind-friendly palette
  pal <- c("#56B4E9", "#D55E00", "#E69F00", "#0072B2", "#009E73","#999999")
  
  ## function to set marker color ##
  getColor <- function(lpd_qc) {
    sapply(lpd_qc$taxa, function(taxa) {
      if(taxa == "amphibiens") {
        pal[1] } else if(taxa == "mammifères") {
          pal[2] } else if(taxa == "oiseaux") {
            pal[3] } else if(taxa == "poissons") {
              pal[4] } else if(taxa == "reptiles"){
                pal[5] } else {
                  pal[6] }
    }
    )
  }
  
  ## POP-UPS ##
  get_popup_content <- function(lpd_qc){
    paste0(
      "<b>", lpd_qc$common_name, "</b>",
      "<br><i>", gsub("_", " ", lpd_qc$scientific_name), "</i>",
      "<br><b>Source: </b>", lpd_qc$intellectual_rights
    )
  }
  
  ## MAP ##
    leaflet::leaflet() %>%
    leaflet::addTiles() %>%
    # leaflet::addCircleMarkers(
    #   data = lpd_qc,
    #   layerId = lpd_qc[["scientific_name"]],
    #   label = lpd_qc[["scientific_name"]],
    #   popup = ~get_popup_content(lpd_qc),
    #   color = unname(getColor(lpd_qc)),
    #   stroke = FALSE,
    #   fillOpacity = .7,
    #   radius = 5
    # ) %>%
    leaflet::addLegend(
      "topleft",
      colors = pal[c(1:5)],
      labels = c("Amphibiens", "Mammifères", "Oiseaux", "Poissons", "Reptiles"),
      opacity = 1
    )
}


filter_lpd_qc <- function(target_taxa){
  ## SELECTION ##
  lpd_qc <- tableaulpi::lpd_qc_fake
  
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

filter_lpd_qc("tous")

filter_lpd_qc("reptiles")
