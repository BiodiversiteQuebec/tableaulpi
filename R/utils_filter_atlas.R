#' function to filter the dataset to selected taxa
#'
#' @description A utils function
#'
#' @return The return value, if any, from executing the utility.
#'
#' @noRd
#' @export

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