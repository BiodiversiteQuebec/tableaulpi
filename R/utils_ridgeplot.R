# Script to make a ridge plot of growth rates

#' @import ggridges

make_ridgeplot <- function(){
  
  # create colorblind-friendly palette
  pal <- c("#984ea3", "#56B4E9", "#D55E00", "#E69F00", "#0072B2", "#009E73")
  names(pal) <- c("tous", "amphibiens", "mammifères", "oiseaux", "poissons", "reptiles")
  
  # create ggplot theme options to apply to all figures
  plot_theme <- ggplot2::theme_classic() +
    ggplot2::theme(axis.text = ggplot2::element_text(size = 13),
                   axis.title = ggplot2::element_text(size = 15))
  
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
    ggplot2::labs(y = "", 
         x = "Taux de croissance moyen") +
    plot_theme +
    ggplot2::coord_cartesian(xlim = c(-max(abs(temp$perc_change)), 
                                      max(abs(temp$perc_change)))) +
    ggplot2::theme(legend.position = "none") +
    ggplot2::scale_x_continuous(labels = function(x) paste0(x, "%")) # Add percent sign 
  return(p)
}