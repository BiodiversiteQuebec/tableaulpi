# plotly of index trend ========================================================

make_indextrend <- function(taxa){
  
  # create colorblind-friendly palette
  pal <- c("#984ea3", "#56B4E9", "#D55E00", "#E69F00", "#0072B2", "#009E73")
  names(pal) <- c("tous", "amphibiens", "mammifères", "oiseaux", "poissons", "reptiles")
  # create ggplot theme options to apply to all figures
  plot_theme <- theme_classic() +
    theme(axis.text = element_text(size = 13),
          axis.title = element_text(size = 15))
  
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
  p <- ggplot() +
    # plot all taxa trends in grey
    geom_line(data = lpi_df, 
              aes(x = year, y = lpi_b, group = taxa), 
              col = "grey90", 
              lwd = .4) +
    # plot uncertainty interval for chosen taxa
    geom_ribbon(data = lpi_taxa,
                aes(x = year, ymin = lpi_cilo, ymax = lpi_cihi),
                fill = unname(pal[taxa]),
                colour = NA, # remove ribbon border
                alpha = .2) +
    # plot trend for chosen taxa in color
    geom_line(data = lpi_taxa,
              aes(x = year, y = lpi), 
              col = unname(pal[taxa]), 
              lwd = .7) +
    # baseline reference
    geom_hline(yintercept = 1, 
               lty = 1, 
               col = "grey20", 
               lwd = .2) +
    labs(y = "Indice Planète Vivante", x = "") +
    plot_theme
  # generate as plotly object
  p <- plotly::ggplotly(p, tooltip = c("lpi")) %>%
    layout(yaxis = list(range = c(0, max(c(abs(lpi_df$lpi_cihi)))+0.1)),
           hovermode = "x unified"
    ) %>%
    style(hoverinfo = "skip", traces = 1) %>%
    style(hoverinfo = "skip", traces = 2) %>%
    style(text = text_lpi, traces = 3)
  return(p)
}
