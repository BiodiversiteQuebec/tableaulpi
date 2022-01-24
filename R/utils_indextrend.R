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
  
  # calculate index for populations to show in the background of the plot
  # lpi_pops <- tableaulpi::make_rlpi_population(target_taxa)
  # removing bc heavy and also not very informative when there are a lot of populations.
  
  # generate a custom string (to appear in tooltip)
  text_lpi <- paste0(
    "LPI en ", lpi$years," = ", lpi$LPI_final,
    "\n(CI: ", lpi$CI_low, ", ", lpi$CI_high, ")"
  )
  
  # plot the LPI trend
  p <- ggplot2::ggplot(lpi, ggplot2::aes(x = years)) +
    # # plot all populations trends in grey
    # ggplot2::geom_line(data = lpi_pops,
    #                    ggplot2::aes(x = years, y = LPI_final, group = population_id),
    #                    col = "grey90",
    #                    lwd = .4) +
    # plot uncertainty interval for chosen taxa
    ggplot2::geom_ribbon(data = lpi, 
                         ggplot2::aes(x = years, ymin = CI_low, ymax = CI_high),
                         fill = unname(pal[target_taxa]),
                         colour = NA, # remove ribbon border
                         alpha = .2) +
    # plot trend for chosen taxa in color
    ggplot2::geom_line(data = lpi, 
                       ggplot2::aes(x = years, y = LPI_final),
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
  p <- plotly::ggplotly(p, tooltip = c("LPI_final")) %>%
    plotly::layout(yaxis = list(range = c(0, max(c(abs(c(lpi$CI_high))))+0.1)),
                   hovermode = "x unified"
    ) %>%
    plotly::style(hoverinfo = "skip", traces = 1) %>%
    plotly::style(hoverinfo = "skip", traces = 2) %>%
    plotly::style(text = text_lpi, traces = 3) %>%
    # remove plotly's zooming option
    plotly::config(modeBarButtonsToRemove = c("zoomIn2d", "zoomOut2d"))
  return(p)
}
