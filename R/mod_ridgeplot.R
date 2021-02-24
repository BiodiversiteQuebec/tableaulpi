#' ridgeplot UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_ridgeplot_ui <- function(id){
  ns <- NS(id)
  tagList(
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
      make_ridgeplot()}
    )
  })
}
    
## To be copied in the UI
# mod_ridgeplot_ui("ridgeplot_ui_1")
    
## To be copied in the server
# mod_ridgeplot_server("ridgeplot_ui_1")
