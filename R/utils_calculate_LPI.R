#' Calculate the Living Planet Index for observations extracted from Atlas
#'
#' @param target_taxa 
#'
#' @import ratlas rlpi dplyr tidyr here
#' @return lpi: a dataframe containing years, LPI values, and lower and upper 95% confidence intervals
#' @export
#'
#' 
calculate_LPI <- function(target_taxa = "Tous"){
  
  # get time series and taxonomic info to observations
  obs <- dplyr::left_join(ratlas::get_timeseries(), 
                          ratlas::get_gen(endpoint="taxa"), 
                          by = c("id_taxa" = "id"))
  obs$id <- as.character(obs$id)
  
  # subset to observations with at least 6 observations in time
  obs <- obs[unlist(lapply(obs$years, length)) >= 6,]
  
  #### Prepare data to create infiles ####
  
  # reformat data for the LPI package
  df <- tidyr::unnest(obs, c(years,values)) %>%
    tidyr::pivot_wider(names_from = years, values_from = values, 
                       names_sort = TRUE, names_prefix = "X") %>%
    dplyr::rename("ID" = "id", "Binomial" = "scientific_name")
  df$Binomial <- gsub(" ", "_", df$Binomial)

  
  # Subset to selected taxa 
  # Doing this after pivot_wider is important to ensure all the column names are there
  # i.e. from 1950 to the 2018
  stopifnot(target_taxa %in% c("Poissons", "Amphibiens", "Oiseaux", "Mammifères", "Reptiles", "Tous"))
  if (target_taxa != "Tous") {
    df <- subset(df, df$species_gr %in% target_taxa)
  }
  
  # Constructing infiles for rlpi package
  
  # Select populations in the dataset by setting all to TRUE
  index_vector = rep(TRUE, nrow(df))
  
  # Create infile for Canada populations
  setwd(here::here("data/rlpi"))
  checker_infile_name <- rlpi::create_infile(df, 
                                             index_vector = index_vector, 
                                             name = target_taxa,
                                             start_col_name = "X1950", 
                                             end_col_name = "X2018"
  )
  
  # index with 10000 bootstraps without weightings
  lpi <- rlpi::LPIMain(checker_infile_name, 
                       REF_YEAR = 1990, 
                       PLOT_MAX = 2018, 
                       BOOT_STRAP_SIZE = 1000, 
                       use_weightings = 0, 
                       goParallel = TRUE,
                       VERBOSE = FALSE, save_plots = 0, plot_lpi = 0,
                       SHOW_PROGRESS = FALSE,
                       force_recalculation = TRUE)
  
  # Remove NAs (trailing years with no data)
  lpi <- lpi[complete.cases(lpi), ]
  lpi$years <- rownames(lpi) %>% as.numeric()
  
  return(lpi)
}
