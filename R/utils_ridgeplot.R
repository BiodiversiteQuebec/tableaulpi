#' Ridgeplot of the density of population growth rates per taxa
#'
#' @import ggplot2 ggridges dplyr
#' @return A ridgeplot of the density of all population growth rates for each taxa, stacked vertically to allow comparison between groups. The plot is themed with \code{theme_mapselector()}.
#' @export
#'
make_ridgeplot <- function(){

  # create colorblind-friendly palette
  pal <- c("#984ea3", "#56B4E9", "#D55E00", "#E69F00", "#0072B2", "#009E73")
  names(pal) <- c("tous", "amphibiens", "mammifères", "oiseaux", "poissons", "reptiles")
  
  # Import population growth rates
  pop_trends <- readRDS("data/lpi_trend_populations.RDS")
  # prepare data
  temp <- dplyr::filter(pop_trends, taxa != "tous") %>%
    # create a column for % change since 1990
    dplyr::mutate(perc_change = (dt-1)*100)
  
  # generate ridgeplot
  p <- ggplot2::ggplot(data = temp) +
    ggridges::geom_density_ridges(
      ggplot2::aes(x = perc_change, 
                   y = taxa, 
                   fill = taxa), 
      lwd = .2) +
    ggplot2::scale_fill_manual(values = pal) +
    ggplot2::geom_vline(xintercept = 0, 
                        linetype = 2, 
                        color = "black") + 
    ggplot2::labs(y = "", x = "Taux de croissance moyen") +
    ggplot2::coord_cartesian(xlim = c(-max(abs(temp$perc_change)), 
                                      max(abs(temp$perc_change)))) +
    theme_mapselector() +
    ggplot2::theme(legend.position = "none") +
    ggplot2::scale_x_continuous(labels = function(x) paste0(x, "%")) # Add percent sign 
  return(p)
}