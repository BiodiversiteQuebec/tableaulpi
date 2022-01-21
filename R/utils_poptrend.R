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
  
  lambda <- read.csv("~/Documents/GitHub/tableaulpi/data/rlpi/default_infile_pops_PopLambda.txt")
  lambda[lambda == -1] <- NA

  temp <- data.frame(
    "id" = lambda$population_id,
    "mean_lambda" = lambda[,3:ncol(lambda)] %>% as.matrix() %>% apply(1, mean, na.rm = TRUE) 
  )
  
  lambda <- left_join(temp, 
                      subset(obs, select = c(id, scientific_name, qc_status, exotic, species_gr)),
                      by = "id")
  
  lambda$perc <- round(lambda$mean_lambda*100, digits = 2)
  
  # set up plotly object
  plotly::plot_ly(showscale = FALSE) %>%
    # format points
    plotly::add_markers(
      data = lambda,
      x = ~perc,
      y = ~species_gr,
      color = ~perc,
      colors = colorRampPalette(RColorBrewer::brewer.pal(10,"RdYlGn"))(length(unique(lambda$perc))),
      marker = list(size = 20, line = list(width = .2, color = "grey80")),
      text = ~scientific_name, # switch to common name
      hovertemplate = paste('<b>%{text}</b>',
                            "<br>L'abondance de cette population <br>a changé de %{x:1}% depuis 1990.<br>",
                            "<extra></extra>")
    ) %>%
    plotly::colorbar(limits = c(-100,100), title = "Taux de croissance") %>%
    # axis and label stuff
    plotly::layout(
      xaxis = list(range = c(-100, 100),
                   title = "Taux de croissance (moyenne)"),
      # hide y axis
      yaxis = list(
        title = "",
        zeroline = FALSE,
        showline = FALSE,
        showticklabels = FALSE,
        showgrid = FALSE)
    )
}
