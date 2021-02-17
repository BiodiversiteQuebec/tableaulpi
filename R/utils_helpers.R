# Utils for the dashboard and miscellaneous functions

# taxa options
taxa <- c("tous", "amphibiens", "mammifères", "oiseaux", "poissons", "reptiles")

# plot of index trend
#' @export
tab_fulltrend <- function(title = "Tendance de l'indice", 
                          outputFunction = plotly::plotlyOutput, 
                          id = "indextrend"){
  tabPanel(title, outputFunction(id))
}