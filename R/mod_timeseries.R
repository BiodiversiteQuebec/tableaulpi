#' timeseries UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_timeseries_ui <- function(id){
  ns <- NS(id)
  tagList(
    div(
    plotOutput(outputId = ns("timeseries"), width = "100%"),
    htmlOutput(ns("blurb"))
    )
  )
}
    
#' timeseries Server Functions
#'
#' @noRd 
mod_timeseries_server <- function(id, clicked_population){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
  
    output$timeseries <- renderPlot({
      make_timeseries(clicked_population())}
    )
    
    output$blurb <- renderUI({
      
      # write some context
      tags$div(id = "blurbid", 
               class = "blurbtext",
               tags$p("Chaque point est une mesure de l'abondance de la population à un point dans le temps. L'Indice Planète Vivante se base sur le taux de changement entre ces points pour estimer une tendance moyenne des changements d'abondance de plusieurs populations.")
      )})
  })
}
    
## To be copied in the UI
# mod_timeseries_ui("rawdata_ui_1")
    
## To be copied in the server
# mod_timeseries_server("timeseries_ui_1")
