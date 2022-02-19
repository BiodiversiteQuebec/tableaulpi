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
    # fluidRow(shinyWidgets::sliderTextInput("target_year",
    #                                        label = NULL,
    #                                        choices = as.character(c(1950:2018)),
    #                                        selected = c("1990","2018"))),
    fluidRow(plotly::plotlyOutput(outputId = ns("ridgeplot"), width = "100%"))
  )
}
    
#' ridgeplot Server Functions
#'
#' @noRd 
mod_ridgeplot_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns
    
    output$ridgeplot <- plotly::renderPlotly({make_ridgeplot()})
  })
}
    
## To be copied in the UI
# mod_ridgeplot_ui("ridgeplot_ui_1")
    
## To be copied in the server
# mod_ridgeplot_server("ridgeplot_ui_1")

