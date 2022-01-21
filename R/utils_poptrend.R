#' Plot each population growth rate since 1990
#' 
#' Makes a plot to compare individual populations' growth rates over the entire time frame of the estimated LPI trend (1990-2018).
#'
#' @param taxachoice Species group selected by the user.
#' @import ggplot2 dplyr plotly
#'
#' @return A "bubbleplot" using \code{plotly} where each population is shown as a filled circle, called a "bubble" here. Each bubble's fill colour is scaled to the population's population growth rate (%). Bubbles are arranged on the \code{x} axis according to the population's growth rate (%) since 1990. The \code{y} axis is a set of random positions to differentiate the circles more easily. On hover, the common name of the population and a sentence explaining this population change rate (%) appears over the circle.
#' @export

make_poptrend <- function(taxachoice){
  
  # read ratlas data
  obs <- dplyr::left_join(ratlas::get_timeseries(), 
                          ratlas::get_gen(endpoint="taxa"), 
                          by = c("id_taxa" = "id"))
  
  # Subset to selected taxa 
  stopifnot(taxachoice %in% c("Poissons", "Amphibiens", "Oiseaux", "Mammifères", "Reptiles", "Tous"))
  if (taxachoice != "Tous") {
    obs <- subset(obs, obs$species_gr == taxachoice)
  } 

  # split into list per series to calculate log-ratio index for each population
  obs <- dplyr::group_split(obs, by = as.factor(id)) %>%
    lapply(tableaulpi::lpi_population) %>%
    dplyr::bind_rows() # rebind together
  obs$mean_dt[is.infinite(obs$mean_dt)] <- NA
  
  # make tooltip templates for hovering over each population point
  obs$hovertemplate <- paste("<b>%{y}</b>: <br>L'abondance de cette population est, en moyenne, <br>restée stable annuellement (%{x:1}%) <br>entre %{text}. <extra></extra>")
  obs$hovertemplate[which(obs$mean_dt < -5)] <- paste("<b>%{y}</b>: <br>Cette population a, en moyenne, <br>diminué annuellement (%{x:1}%) <br>entre %{text}. <extra></extra>")
  obs$hovertemplate[which(obs$mean_dt > 5)] <- paste("<b>%{y}</b>: <br>Cette population a, en moyenne, <br>augmenté annuellement (%{x:1}%) <br>entre %{text}. <extra></extra>")
  obs$year_text <- apply(obs, 1, function(x) {
    paste(head(unlist(x$years), 1), "et", tail(unlist(x$years), 1))
  })
  
  # set up plotly object
  plotly::plot_ly(showscale = FALSE) %>%
    # format points
    plotly::add_markers(
      data = obs,
      x = ~mean_dt,
      y = ~scientific_name,
      color = ~mean_dt,
      colors = colorRampPalette(RColorBrewer::brewer.pal(10,"RdYlGn"))(length(unique(obs$mean_dt))),
      marker = list(size = 20, line = list(width = .2, color = "grey80")),
      text = ~year_text,
      hovertemplate = ~hovertemplate
    ) %>%
    plotly::colorbar(limits = c(-100,100), title = "Taux de croissance") %>%
    # axis and label stuff
    plotly::layout(
      xaxis = list(range = c(-100,100),
                   title = "Taux de croissance moyenne annuelle"),
      # hide y axis
      yaxis = list(
        title = "Espèces",
        zeroline = FALSE,
        showline = FALSE,
        showticklabels = FALSE,
        showgrid = TRUE)
    )
}
