#' lpi_time_series UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_lpi_time_series_ui <- function(id){
  ns <- NS(id)
  tagList(
    plotOutput(outputId = ns("indextrend"), width = "100%")
    #plotly::plotlyOutput(outputId = ns("indextrend"), width = "100%")
  )
}

#' lpi_time_series Server Functions
#'
#' @noRd
mod_lpi_time_series_server <- function(id, taxachoice){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    #output$indextrend <- plotly::renderPlotly({
    output$indextrend <- renderPlot({
      make_indextrend(taxa = taxachoice())}
      )
  })
}

## To be copied in the UI
# mod_lpi_time_series_ui("lpi_time_series_ui_1")

## To be copied in the server
# mod_lpi_time_series_server("lpi_time_series_ui_1")




testapp_lpi_timeseries <- function(){
  ui <- fluidPage(
    mod_lpi_time_series_ui("test")
  )

  server <-  function(input, output, session) {

    mod_lpi_time_series_server("test",
                               taxachoice = reactive("tous"))
  }
  shinyApp(ui, server)
}

testapp_lpi_timeseries()
