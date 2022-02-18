#' map_summarytable
#'
#' @description A utils function to generate summary statistics about the dataset shown on the map.
#' 
#' @param target_taxa The species gorup selection from user input (input$taxa).
#'
#' @return A text output of the value of the selected summary statistic.
#'
#' @noRd

make_map_summarytable <- function(target_taxa){
  
  # get time series and taxonomic info to observations
  obs <- ratlas::get_timeseries() 
  obs <- obs %>% 
    dplyr::left_join(ratlas::get_gen(endpoint="taxa", 
                                        id = unique(obs$id_taxa)), 
                     by = c("id_taxa" = "id")) %>%
    dplyr::left_join(ratlas::get_datasets(id = unique(obs$id_datasets)),
                     by = c("id_datasets" = "id"))
  obs$id <- as.character(obs$id)
  
  # Subset to selected taxa 
  stopifnot(target_taxa %in% c("Poissons", "Amphibiens", "Oiseaux", "Mammifères", "Reptiles", "Tous"))
  if (target_taxa != "Tous") {
    obs <- subset(obs, obs$species_gr %in% target_taxa)
  }
  
  # Make a named list of summary stats
  d <- list(
    "n_sp" = length(unique(obs$id_taxa)),
    "n_pop" = length(unique(obs$id)),
    # "n_sp_vul" = length(obs$scientific_name[which(obs$qc_status == "Vulnérable")]),
    # "n_sp_men" = length(obs$scientific_name[which(obs$qc_status == "Menacée")]),
    # "n_sp_sus" = length(obs$scientific_name[which(obs$qc_status == "Susceptible")]),
    "mean_tslength" = unlist(lapply(obs$years, length)) %>% mean(na.rm = TRUE) %>% floor(),
    "min_tslength" = unlist(lapply(obs$years, length)) %>% min(na.rm = TRUE) %>% floor(),
    "max_tslength" = unlist(lapply(obs$years, length)) %>% max(na.rm = TRUE) %>% floor()
  )
  
  d <- lapply(d, as.character)
  x <- data.frame(
    "Sommaire" = c("Populations", 
                   "Espèces", 
                   "Durée moyenne des suivis",
                   "Durée des suivis"),
    "Valeur" = c(d["n_pop"]$n_pop, 
                 d["n_sp"]$n_sp, 
                 paste(d["mean_tslength"]$mean_tslength, "ans"),
                 paste("Entre", d["min_tslength"]$min_tslength, "et", d["max_tslength"]$max_tslength, "ans")
    )
  )
  
  return(x)
  
}