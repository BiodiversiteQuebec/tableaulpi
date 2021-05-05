#' Plot the Living Planet Index (LPI) trend
#'
#' Function to plot each taxonomic group's LPI trend through time, where all unselected groups' trends are plotted in grey in the background, while the selected taxonomic group is plotted in colour and with its confidence intervals. There is also a plotly functionality to see the LPI value for each year when hovering over the plot.
#'
#' @param taxa can take the inputs "tous" (all populations in Québec), "amphibiens" , "mammifères", "oiseaux", "poissons", "reptiles" from the Shiny user's input.
#' 
#' @import ggplot2 plotly
#' 
#' @return A plotly of the Living Planet Index trend through time, with the selected taxonomic group highlighted and shown with confidence intervals.
#' 
#' @export
#' 
make_indextrend <- function(taxa){

  # create colorblind-friendly palette
  pal <- c("#984ea3", "#56B4E9", "#D55E00", "#E69F00", "#0072B2", "#009E73")
  names(pal) <- c("tous", "amphibiens", "mammifères", "oiseaux", "poissons", "reptiles")
  
  # create ggplot theme options to apply to all figures
  plot_theme <- ggplot2::theme_classic() +
    ggplot2::theme(axis.text = ggplot2::element_text(size = 13),
                   axis.title = ggplot2::element_text(size = 15))
  
  # Import LPI results per taxa group
  lpi_df <- readRDS("data/lpi_index_taxa.RDS")
  # round so the hover text is nicer
  lpi_df[,c(3:8)] <- apply(lpi_df[,c(3:8)], 2, round, digits = 2)
  # filter for subset of values according to user's choice of taxa
  lpi_taxa <- lpi_df[which(lpi_df$taxa == taxa),]
  
  # generate a custom string (to appear in tooltip)
  text_lpi <- paste0(
    "LPI en ", lpi_taxa$year," = ", lpi_taxa$lpi,
    "\n(CI: ", lpi_taxa$lpi_cilo, ", ", lpi_taxa$lpi_cihi, ")"
  )
  # rename the background lpi trend columns
  lpi_df <- dplyr::rename(lpi_df, "lpi_b" = "lpi")
  
  # plot the LPI trend
  p <- ggplot2::ggplot() +
    # plot all taxa trends in grey
    ggplot2::geom_line(data = lpi_df,
                       ggplot2::aes(x = year, y = lpi_b, group = taxa),
                       col = "grey90",
                       lwd = .4) +
    # plot uncertainty interval for chosen taxa
    ggplot2::geom_ribbon(data = lpi_taxa,
                         ggplot2::aes(x = year, ymin = lpi_cilo, ymax = lpi_cihi),
                         fill = unname(pal[taxa]),
                         colour = NA, # remove ribbon border
                         alpha = .2) +
    # plot trend for chosen taxa in color
    ggplot2::geom_line(data = lpi_taxa,
                       ggplot2::aes(x = year, y = lpi),
                       col = unname(pal[taxa]),
                       lwd = .7) +
    # baseline reference
    ggplot2::geom_hline(yintercept = 1,
                        lty = 1,
                        col = "grey20",
                        lwd = .2) +
    ggplot2::labs(y = "Indice Planète Vivante", x = "") +
    plot_theme
  # generate as plotly object
  p <- plotly::ggplotly(p, tooltip = c("lpi")) %>%
    plotly::layout(yaxis = list(range = c(0, max(c(abs(lpi_df$lpi_cihi)))+0.1)),
                   hovermode = "x unified"
    ) %>%
    plotly::style(hoverinfo = "skip", traces = 1) %>%
    plotly::style(hoverinfo = "skip", traces = 2) %>%
    plotly::style(text = text_lpi, traces = 3) %>%
    # remove plotly's zooming option
    plotly::config(modeBarButtonsToRemove = c("zoomIn2d", "zoomOut2d"))
  return(p)
}
