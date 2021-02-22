# Index to make a bubble plot of each populations' trend, where each bubble's fill
# colour is scaled to the population's population growth rate (%). The x axis is 
# arbitrary, while the y axis indicates growth rate (%).

#' @import dplyr

make_poptrend <- function(taxachoice){
  
  # Import population growth rates
  pop_trends <- readRDS("data/lpi_trend_populations.RDS")
  # prepare data
  temp <- dplyr::filter(pop_trends, taxa != "tous") %>%
    # create a column for % change since 1990
    dplyr::mutate(perc_change = (dt-1))
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
      yaxis = list(range = c(-max(abs(pop_trends$dt-1))-0.02,
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
