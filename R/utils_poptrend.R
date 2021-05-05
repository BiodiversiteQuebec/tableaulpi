#' Plot each population growth rate since 1990
#' 
#' Makes a plot to compare individual populations' growth rates over the entire time frame of the estimated LPI trend (1990-2018).
#'
#' @param taxachoice 
#' @import ggplot2 dplyr plotly
#'
#' @return A "bubbleplot" using \code{plotly} where each population is shown as a filled circle, called a "bubble" here. Each bubble's fill colour is scaled to the population's population growth rate (%). Bubbles are arranged on the \code{x} axis according to the population's growth rate (%) since 1990. The \code{y} axis is a set of random positions to differentiate the circles more easily. On hover, the common name of the population and a sentence explaining this population change rate (%) appears over the circle.
#' @export

make_poptrend <- function(taxachoice){
  
  # Index to make a bubble plot of each populations' trend, where each bubble's fill
  # colour is scaled to the population's population growth rate (%). The x axis is 
  # arbitrary, while the y axis indicates growth rate (%).
  
  #' @import dplyr
  
  # Import population growth rates
  pop_trends <- readRDS("data/lpi_trend_populations.RDS")
  # prepare data
  temp <- dplyr::filter(pop_trends, taxa != "tous") %>%
    # create a column for % change since 1990
    dplyr::mutate(perc_change = (dt-1))
  # set random seed
  set.seed(20)
  # assign random y axis positions to each population
  temp$position <- runif(nrow(temp), min = 0.1, max = 1)
  
  # select taxa of choice
  if(taxachoice != "tous"){
    temp <- dplyr::filter(temp, taxa == taxachoice)
  }
  
  # set up plotly object
  plotly::plot_ly(showscale = FALSE) %>%
    # format points
    plotly::add_markers(
      data = temp,
      x = ~perc_change,
      y = ~position,
      color = ~perc_change,
      colors = colorRampPalette(RColorBrewer::brewer.pal(10,"RdYlGn"))(length(unique(temp$perc_change))),
      marker = list(size = 20, line = list(width = .2, color = "grey80")),
      text = ~common_name,
      hovertemplate = paste('<b>%{text}</b>',
                            "<br>L'abondance de cette population <br>a changé de %{x:.1%} depuis 1990.<br>",
                            "<extra></extra>")
    ) %>%
    plotly::colorbar(limits = c(-max(abs(pop_trends$dt-1))-0.02,
                                max(abs(pop_trends$dt-1))+0.02)) %>%
    # axis and label stuff
    plotly::layout(
      xaxis = list(range = c(-max(abs(pop_trends$dt-1))-0.02,
                             max(abs(pop_trends$dt-1))+0.02),
                   title = "Taux de croissance"),
      # hide y axis
      yaxis = list(
        title = "",
        zeroline = FALSE,
        showline = FALSE,
        showticklabels = FALSE,
        showgrid = FALSE)
    )
}
