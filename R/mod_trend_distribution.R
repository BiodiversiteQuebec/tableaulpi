#' trend_distribution UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_trend_distribution_ui <- function(id){
  ns <- NS(id)
  tagList(
    fluidRow(sliderInput(ns("target_years"),
                         label = "Explorez comment les tendances des populations varient dans le temps:",
                         min = 1950, max = 2018,
                         value = c(1990, 2018),
                         step = 1,
                         round = TRUE,
                         animate = FALSE,
                         sep = "", width = '100%')),
    fluidRow(
      shinycssloaders::withSpinner(
        plotly::plotlyOutput(outputId = ns("trend_distribution"), width = "100%"),
        type = 8,
        color = "#7bb5b1", 
        size = 1
      ))
  )
}

#' trend_distribution Server Functions
#'
#' @noRd
mod_trend_distribution_server <- function(id, target_years){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    output$trend_distribution <- plotly::renderPlotly({make_trend_distribution(input$target_years)})
  })
}

## To be copied in the UI
# mod_trend_distribution_ui("trend_distribution_ui_1")

## To be copied in the server
# mod_trend_distribution_server("trend_distribution_ui_1")
