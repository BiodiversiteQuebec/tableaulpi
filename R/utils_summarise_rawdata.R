#' Summarise time series data into a descriptive table
#' 
#' Creates a table for a clicked population on the point map. This function can then be used within the \code{summarise_rawdata} module to generate the table on the dashboard in reaction to a click.
#'
#' @param clicked_population Population selected from a user's click on the point map.
#' 
#' @return A table describing the raw time series data.
#' @export

make_summarise_rawdata <- function(clicked_population){
 
  # get time series and taxonomic info to observations
  obs <- ratlas::get_timeseries() 
  obs <- obs %>% 
    dplyr::left_join(ratlas::get_gen(endpoint="taxa", 
                                     id = unique(obs$id_taxa)), 
                     by = c("id_taxa" = "id")) %>%
    dplyr::left_join(ratlas::get_datasets(id = unique(obs$id_datasets)),
                     by = c("id_datasets" = "id"))
  obs$id <- as.character(obs$id)
  obs <- obs[which(obs$id == clicked_population),]
  
  # summarise information about this dataset
  summary_table <- data.frame(
    "Description" = c("Nom scientifique",
                      "Durée du suivi",
                      "Statut de l'espèce (Québec)",
                      "Groupe",
                      "Source des données",
                      "License"
    ),
    "Détails" = c(gsub("_", " ", obs$scientific_name[1]),
                  paste0(min(obs$years[[1]]), "-", max(obs$years[[1]]), 
                         " (", length(obs$years[[1]]), " ans)"),
                  if(is.na(obs$qc_status[1])){"-"} else{obs$qc_status[1]},
                  obs$species_gr[1],
                  paste0(obs$title[1], " par ", obs$creator[1]),
                  paste0(obs$intellectual_rights[1], "(", obs$license[1], ")")
    )
  )
  return(summary_table)
}
  