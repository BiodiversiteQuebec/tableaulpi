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
make_indextrend <- function(target_taxa = "Tous"){

  ## colour palette ##
  pal <- c("Amphibiens" = "#56B4E9",
           "Mammifères" = "#D55E00", 
           "Oiseaux" = "#E69F00", 
           "Poissons" = "#0072B2", 
           "Reptiles" = "#009E73",
           "Tous" = "#999999")
  
  lpi <- tableaulpi::calculate_LPI(target_taxa)
  # round so the hover text is nicer
  lpi[,1:3] <- round(lpi[,1:3], digits = 2)
  
  # plot the LPI trend
  p <- ggplot2::ggplot(data = lpi, 
                       ggplot2::aes(x = years, 
                                    text = paste0(
                                      "IPV en ", years," = ", LPI_final,
                                      "\nIntervale de confiance: ", CI_low, "–", CI_high, ""    ),
                                    group = 1)
                       ) +
    # plot uncertainty interval for chosen taxa
    ggplot2::geom_ribbon(ggplot2::aes(ymin = CI_low, ymax = CI_high),
                         fill = unname(pal[target_taxa]),
                         colour = NA, # remove ribbon border
                         alpha = .2) +
    # plot trend for chosen taxa in color
    ggplot2::geom_line(ggplot2::aes(y = LPI_final),
                       col = unname(pal[target_taxa]),
                       lwd = .7) +
    # baseline reference
    ggplot2::geom_hline(yintercept = 1,
                        lty = 1,
                        col = "grey20",
                        lwd = .2) +
    ggplot2::labs(y = "Indice Planète Vivante", x = "") +
    tableaulpi::theme_mapselector()
  # generate as plotly object
  p <- plotly::ggplotly(p, tooltip = c("text")) %>%
    plotly::layout(hovermode = "x unified",
                   yaxis = list(range = c(0, max(c(abs(c(lpi$CI_high))))+0.1))
    ) %>%
    plotly::style(hoverinfo = "skip", traces = 1) %>%
    # remove plotly's zooming option
    plotly::config(modeBarButtonsToRemove = c("zoomIn2d", "zoomOut2d"))
  return(p)
}
