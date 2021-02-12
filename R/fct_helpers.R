# Functions specific to the Living Planet Index dashboard

library(ggplot2)
library(leaflet)
library(dplyr)
library(plotly)

# point map of populations =====================================================

make_pointmap <- function(taxa){

  # Import sf object of points in the Living Planet Database
  lpd_qc <- readRDS("data/lpd_qc_fake.RDS")

  ## SELECTION ##
  if(taxa != "tous"){
    lpd_qc <- lpd_qc[which(lpd_qc$taxa == taxa),]
  }

  ## PALETTE ##

  # create colorblind-friendly palette
  pal <- c("#56B4E9", "#D55E00", "#E69F00", "#0072B2", "#009E73","#999999")

  ## function to set marker color ##
  getColor <- function(lpd_qc) {
    sapply(lpd_qc$taxa, function(taxa) {
      if(taxa == "amphibiens") {
        pal[1] } else if(taxa == "mammifères") {
        pal[2] } else if(taxa == "oiseaux") {
        pal[3] } else if(taxa == "poissons") {
        pal[4] } else if(taxa == "reptiles"){
        pal[5] } else {
        pal[6] }
    }
    )
  }

  ## POP-UPS ##
  get_popup_content <- function(lpd_qc){
    paste0(
      "<b>", lpd_qc$common_name, "</b>",
      "<br><i>", gsub("_", " ", lpd_qc$scientific_name), "</i>",
      "<br><b>Source: </b>", lpd_qc$intellectual_rights
    )
  }

  ## MAP ##

  # generate leaflet map
  leaflet::leaflet() %>%
    leaflet::addTiles() %>%
    leaflet::addCircleMarkers(
      data = lpd_qc,
      popup = ~get_popup_content(lpd_qc),
      color = unname(getColor(lpd_qc)),
      stroke = FALSE,
      fillOpacity = .7,
      radius = 5
    ) %>%
    leaflet::addLegend(
      "topleft",
      colors = pal[c(1:5)],
      labels = c("Amphibiens", "Mammifères", "Oiseaux", "Poissons", "Reptiles"),
      opacity = 1
      )
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

# plotly of population-level trends ============================================

make_poptrend <- function(taxachoice){

  # Import population growth rates
  pop_trends <- readRDS("data/lpi_trend_populations.RDS")
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
