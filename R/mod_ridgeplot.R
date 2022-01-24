#' ridgeplot UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_ridgeplot_ui <- function(id, spp_menu_title = "Groupe d'espèces"){
  ns <- NS(id)
  tagList(
    radioButtons(ns("target_taxa"), label = spp_menu_title,
                 choiceValues = c("Tous", "Amphibiens", "Mammifères",
                                  "Oiseaux", "Poissons", "Reptiles"),
                 choiceNames = c("Toutes les espèces", "Amphibiens", 
                                 "Mammifères", "Oiseaux", "Poissons", "Reptiles"))
  ,
  plotOutput(outputId = ns("ridgeplot"), width = "100%")
  )
}
    
#' ridgeplot Server Functions
#'
#' @noRd 
mod_ridgeplot_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    
    output$ridgeplot <- renderPlot({
      make_ridgeplot(taxachoice = input$target_taxa)}
    )
  })
}
    
## To be copied in the UI
# mod_ridgeplot_ui("ridgeplot_ui_1")
    
## To be copied in the server
# mod_ridgeplot_server("ridgeplot_ui_1")
