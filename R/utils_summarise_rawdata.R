#' Summarise time series data into a descriptive table
#' 
#' Creates a table for a clicked population on the point map. This function can then be used within the \code{summarise_rawdata} module to generate the table on the dashboard in reaction to a click.
#'
#' @param clicked_population Population selected from a user's click on the point map.
#' 
#' @return A table describing the raw time series data.
#' @export

make_summarise_rawdata <- function(clicked_population){
 
  # import dataset
  df <- readRDS("data/lpd_qc_fake.RDS")
  df <- df[which(df$org_event == clicked_population),]
  
  # summarise information about this dataset
  summary_table <- data.frame(
    "Description" = c("Nom scientifique",
                  "Longueur de la série (années)",
                  "Système",
                  "Groupe d'espèces",
                  "Source"),
    "Détails" = c(gsub("_", " ", df$scientific_name[1]),
                  length(df$year_obs),
                  df$system[1],
                  df$taxa[1],
                  df$intellectual_rights[1])
  )
  return(summary_table)
}
  