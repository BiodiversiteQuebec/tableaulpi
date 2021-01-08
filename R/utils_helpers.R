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

# point map of included populations
#' @export
tab_pointmap <- function(title = "Carte", 
                         outputFunction = leaflet::leafletOutput, 
                         id = "pointmap"){
  tabPanel(title, outputFunction(id))
}

# plot of population-level trends
#' @export
tab_poptrend <- function(title = "Tendance par population", 
                         outputFunction = plotly::plotlyOutput, 
                         id = "poptrend"){
  tabPanel(title, outputFunction(id))
}

# text explaining the index, its context, and its interpretation
#' @export
tab_about <- function(title = "À propos de l'indice", 
                      outputFunction = htmlOutput, 
                      id = "about") 
{
  tabPanel(title, outputFunction(id))
}