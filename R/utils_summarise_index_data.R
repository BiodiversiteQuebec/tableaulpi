#' Summarise the dataset used to calculate the index.
#'
#' @param target_taxa 
#'
#' @return A text output of summary information about the quantity and characteristics of species included in the index.
#' @export
#'
summarise_index_data <- function(target_taxa){
  
  # get time series and taxonomic info to observations
  obs <- dplyr::left_join(ratlas::get_timeseries(), 
                          ratlas::get_gen(endpoint="taxa"), 
                          by = c("id_taxa" = "id"))
  obs$id <- as.character(obs$id)
  
  # subset to observations with at least 6 observations in time
  obs <- obs[unlist(lapply(obs$years, length)) >= 6,]
  
  # Subset to selected taxa 
  stopifnot(target_taxa %in% c("Poissons", "Amphibiens", "Oiseaux", "Mammifères", "Reptiles", "Tous"))
  if (target_taxa != "Tous") {
    obs <- subset(obs, obs$species_gr %in% target_taxa)
  }
  
  # Make a named list of summary stats
  d <- list(
    "n_sp" = length(unique(obs$id_taxa)),
    "sp" = unique(obs$scientific_name),
    "n_pop" = length(unique(obs$id)),
    "sp_status" = table(factor(obs$qc_status, levels = c("Susceptible", "Menacée", "Vulnérable"))),
    "sp_vul" = obs$scientific_name[which(obs$qc_status == "Vulnérable")],
    "sp_men" = obs$scientific_name[which(obs$qc_status == "Menacée")],
    "sp_sus" = obs$scientific_name[which(obs$qc_status == "Susceptible")],
    "summ_tslength" = unlist(lapply(obs$years, length)) %>% summary(na.rm = TRUE) %>% floor(),
    "range_years" = range(unlist(obs$years))
  )
  
  summary_text <- paste(
    "L'Indice Planète Vivante montrée ci-dessous représente la tendance moyenne des changements d'abondances de",
    d$n_pop, 'populations de', d$n_sp, "espèces différentes, suivis pendant, en moyenne,", d$summ_tslength[4], "ans.",
    "\n\nDe ces", d$n_sp, "espèces,", 
    unname(d$sp_status)[1], "espèces sont considérées Susceptibles,", 
    unname(d$sp_status)[2], "espèces sont considérées Menacées, et",
    unname(d$sp_status)[3], "espèces sont considérées Vulnérable."
  )
  
  return(summary_text)
  
}