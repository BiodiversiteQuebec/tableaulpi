#' population_bubbleplot UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_population_bubbleplot_ui <- function(id, spp_menu_title = "Groupe d'espèces"){
  ns <- NS(id)
  tagList(
    radioButtons(ns("target_taxa"), label = spp_menu_title,
                 choiceValues = c("Tous", "Amphibiens", "Mammifères",
                                  "Oiseaux", "Poissons", "Reptiles"),
                 choiceNames = c("Toutes les espèces", "Amphibiens", 
                                 "Mammifères", "Oiseaux", "Poissons", "Reptiles")),
    plotly::plotlyOutput(outputId = ns("poptrend"), width = "100%")
  )
}
    
#' population_bubbleplot Server Functions
#'
#' @noRd 
mod_population_bubbleplot_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    output$poptrend <- plotly::renderPlotly({
      make_poptrend(taxachoice = input$target_taxa)}
    )
  })
}
    
## To be copied in the UI
# mod_population_bubbleplot_ui("population_bubbleplot_ui_1")
    
## To be copied in the server
# mod_population_bubbleplot_server("population_bubbleplot_ui_1")
