#' trend_perpopulation UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_trend_perpopulation_ui <- function(id, spp_menu_title = "Groupe d'espèces", start_sel = "Tous"){
  ns <- NS(id)
  tagList(
    fluidRow(
      shinyWidgets::radioGroupButtons(ns("target_taxa"),
                                    label = spp_menu_title,
                                    choiceValues = list("Tous", "Amphibiens", "Mammifères", "Oiseaux", "Poissons", "Reptiles"),
                                    choiceNames = list(HTML("<i class='finature-collection nature-collection-landscape-1'>Tous</i>"),
                                                       HTML("<i class='fianimals animals-010-frog'>Amphibiens</i>"),
                                                       HTML("<i class='fianimals animals-015-squirrel'>Mammifères</i>"),
                                                       HTML("<i class='fianimals animals-020-bird'>Oiseaux</i>"),
                                                       HTML("<i class='finature-collection nature-collection-fish'>Poissons</i>"),
                                                       HTML("<i class='fianimals animals-038-turtle'>Reptiles</i>")),
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
    
#' trend_perpopulation Server Functions
#'
#' @noRd 
mod_trend_perpopulation_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    output$poptrend <- plotly::renderPlotly({
      make_poptrend(target_taxa = input$target_taxa)}
    )
  })
}
    
## To be copied in the UI
# mod_trend_perpopulation_ui("trend_perpopulation_ui_1")
    
## To be copied in the server
# mod_trend_perpopulation_server("trend_perpopulation_ui_1")
