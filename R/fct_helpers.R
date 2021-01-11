# Functions specific to the Living Planet Index dashboard

library(ggplot2)
library(leaflet)
library(dplyr)

# point map of populations =====================================================

make_pointmap <- function(){
  
  # Import sf object of points in the Living Planet Database
  lpd_qc <- readRDS("data/lpd_qc_fake.rds")
  
  # create colorblind-friendly palette
  pal <- c("#56B4E9", "#D55E00", "#E69F00", "#0072B2", "#009E73", "#999999")
  palvalues <- c(taxa[2:length(taxa)], "inconnu")
  
  # add colour column
  lpd_qc$color <- pal[6]
  lpd_qc$color[which(lpd_qc$taxa == "amphibiens")] <- pal[1]
  lpd_qc$color[which(lpd_qc$taxa == "mammifères")] <- pal[2]
  lpd_qc$color[which(lpd_qc$taxa == "oiseaux")] <- pal[3]
  lpd_qc$color[which(lpd_qc$taxa == "poissons")] <- pal[4]
  lpd_qc$color[which(lpd_qc$taxa == "reptiles")] <- pal[5]
  
  # generate leaflet map
  leaflet::leaflet() %>%
    leaflet::addTiles() %>%
    leaflet::addCircles(
      data = lpd_qc,
      color = lpd_qc$color,
      label = lpd_qc$common_name,
      fillOpacity = 1) %>%
    leaflet::addLegend(
      "topright",
      colors = pal,
      labels = palvalues,
      opacity = 1)
}



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
  lpi_df <- readRDS("data/lpi_index_taxa.rds")
   # filter for subset of values according to user's choice of taxa
  lpi_df <- lpi_df[which(lpi_df$taxa == taxa),]
  # get y axis limits
  ylimits <- c(-max(abs(lpi_df$lpi_cihi))+1, max(abs(lpi_df$lpi_cihi)))

  # plot the LPI trend
  p <- ggplot(data = lpi_df, aes(x = year)) +
    scale_fill_manual(values = pal) +
    geom_ribbon(aes(ymin = lpi_cilo, 
                    ymax = lpi_cihi),
                fill = unname(pal[taxa]), 
                alpha = .7) +
    geom_line(aes(y = lpi), 
              col = "white", 
              lwd = .5) +
    # baseline reference
    geom_hline(yintercept = 1, 
               lty = 2, 
               col = "black", 
               lwd = .5) +
    labs(y = "Indice Planète Vivante", x = "") +
    # set limits
    coord_cartesian(ylim = ylimits) +
    plot_theme
  # generate as plotly object
  plotly::ggplotly(p)
}


# plotly of population-level trends ============================================

make_poptrend <- function(taxachoice){
  
  # Import population growth rates
  pop_trends <- readRDS("data/lpi_trend_populations.rds")
  # prepare data
  temp <- dplyr::filter(pop_trends, taxa != "tous") %>%
    # create a column for % change since 1990
    mutate(perc_change = (dt-1))
  # set random seed
  set.seed(20)
  # assign random y axis positions to each population
  temp$position <- runif(nrow(temp), min = 0.2, max = 2.8)
  
  # select taxa of choice
  if(taxachoice != "tous"){
    temp <- filter(temp, taxa == taxachoice)
  }
  
  # set up plotly object
  plotly::plot_ly(showscale = FALSE) %>%
    # format points
    plotly::add_markers(
      data = temp, 
      y = ~perc_change, 
      x = ~position, 
      color = ~perc_change,
      colors = colorRampPalette(RColorBrewer::brewer.pal(10,"RdYlGn"))(length(unique(temp$perc_change))),
      marker = list(size = 20, line = list(width = .2, color = "grey80")),
      text = ~common_name,
      hovertemplate = paste('<b>%{text}</b>',
                            "<br>L'abondance de cette population <br>a changé de %{y:.1%} depuis 1990.<br>",
                            "<extra></extra>")
    ) %>%
    plotly::colorbar(limits = c(-max(abs(pop_trends$dt-1))-0.02, 
                        max(abs(pop_trends$dt-1))+0.02)) %>% 
    plotly::hide_colorbar()   %>% # hide it! cramps the plot
    # axis and label stuff
    plotly::layout(
      title = "Tendances par population",
      yaxis = list(title = "Taux de croissance moyenne depuis 1990 (%)",
                   range = c(-max(abs(pop_trends$dt-1))-0.02, 
                             max(abs(pop_trends$dt-1))+0.02)),
      # hide y axis
      xaxis = list(
        title = "",
        zeroline = FALSE,
        showline = FALSE,
        showticklabels = FALSE,
        showgrid = FALSE)
    )
}

# overview of results (interpretations) ========================================