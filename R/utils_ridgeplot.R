#' Ridgeplot of the density of population growth rates per taxa
#'
#' @import ggplot2 ggridges dplyr
#' @return A ridgeplot of the density of all population growth rates for each taxa, stacked vertically to allow comparison between groups. The plot is themed with \code{theme_mapselector()}.
#' @export
#'
#'
make_ridgeplot <- function(taxachoice){

  ## colour palette ##
  pal <- c("Amphibiens" = "#56B4E9",
           "Mammifères" = "#D55E00", 
           "Oiseaux" = "#E69F00", 
           "Poissons" = "#0072B2", 
           "Reptiles" = "#009E73",
           "#999999")
  
  # read ratlas data
  obs <- dplyr::left_join(ratlas::get_timeseries(), 
                          ratlas::get_gen(endpoint="taxa"), 
                          by = c("id_taxa" = "id"))
  
  # Change palette to highlight selected taxa, and grey out other taxa
  stopifnot(taxachoice %in% c("Poissons", "Amphibiens", "Oiseaux", "Mammifères", "Reptiles", "Tous"))
  if (taxachoice  != "Tous") {
    pal[which(names(pal) != taxachoice)] <- "grey"
  } 
  
  # split into list per series to calculate log-ratio index for each population
  obs <- dplyr::group_split(obs, by = as.factor(id)) %>%
    lapply(tableaulpi::lpi_population) %>%
    dplyr::bind_rows() # rebind together
  obs$mean_dt[is.infinite(obs$mean_dt)] <- NA
  
  
  # generate ridgeplot
  p <- ggplot2::ggplot(data = obs) +
    ggridges::geom_density_ridges(
      ggplot2::aes(x = mean_dt, 
                   y = species_gr, 
                   fill = species_gr), 
      lwd = .2, alpha = .9) +
    ggplot2::scale_fill_manual(values = pal) +
    ggplot2::geom_vline(xintercept = 0, 
                        linetype = 2, 
                        color = "black") + 
    ggplot2::labs(y = "", x = "Taux de croissance moyen") +
    ggplot2::coord_cartesian(xlim = c(-max(abs(obs$mean_dt), na.rm = TRUE), 
                                      max(abs(obs$mean_dt), na.rm = TRUE))) +
    tableaulpi::theme_mapselector() +
    ggplot2::theme(legend.position = "none") +
    ggplot2::scale_x_continuous(labels = function(x) paste0(x, "%")) # Add percent sign 
  return(p)
}