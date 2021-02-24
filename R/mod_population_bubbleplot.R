#' population_bubbleplot UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_population_bubbleplot_ui <- function(id){
  ns <- NS(id)
  tagList(
    plotly::plotlyOutput(outputId = ns("poptrend"), width = "100%")
  )
}
    
#' population_bubbleplot Server Functions
#'
#' @noRd 
mod_population_bubbleplot_server <- function(id, taxachoice){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    output$poptrend <- plotly::renderPlotly({
      make_poptrend(taxachoice = taxachoice())}
    )
  })
}
    
## To be copied in the UI
# mod_population_bubbleplot_ui("population_bubbleplot_ui_1")
    
## To be copied in the server
# mod_population_bubbleplot_server("population_bubbleplot_ui_1")
