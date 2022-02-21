#' population_bubbleplot UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_population_bubbleplot_ui <- function(id, spp_menu_title = "Groupe d'espèces", start_sel = "Tous"){
  ns <- NS(id)
  tagList(
    fluidRow(
      shinyWidgets::radioGroupButtons(ns("target_taxa"),
                                    label = spp_menu_title,
                                    choiceValues = list("Tous", "Amphibiens", "Mammifères", "Oiseaux", "Poissons", "Reptiles"),
                                    choiceNames = list(HTML("<i class='finature-collection nature-collection-landscape-1'></i>"),
                                                       HTML("<i class='fianimals animals-010-frog'></i>"),
                                                       HTML("<i class='fianimals animals-015-squirrel'></i>"),
                                                       HTML("<i class='fianimals animals-020-bird'></i>"),
                                                       HTML("<i class='finature-collection nature-collection-fish'></i>"),
                                                       HTML("<i class='fianimals animals-038-turtle'></i>")),
                                    #direction = "vertical",
                                    status = 'primary fibuttons', 
                                    size = "sm", 
                                    justified = TRUE, 
                                    selected = start_sel)
      ),
    fluidRow(
      shinycssloaders::withSpinner(
        plotly::plotlyOutput(outputId = ns("poptrend"), width = "100%"),
        type = 8,
        color = "#7bb5b1", 
        size = 1
        )
  )
  )
}
    
#' population_bubbleplot Server Functions
#'
#' @noRd 
mod_population_bubbleplot_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    output$poptrend <- plotly::renderPlotly({
      make_poptrend(target_taxa = input$target_taxa)}
    )
  })
}
    
## To be copied in the UI
# mod_population_bubbleplot_ui("population_bubbleplot_ui_1")
    
## To be copied in the server
# mod_population_bubbleplot_server("population_bubbleplot_ui_1")
