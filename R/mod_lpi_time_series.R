#' lpi_time_series UI Function
#'
#' @description A shiny Module to show the LPI trend line plot for a selected taxonomic group, with a loading spinner.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList

mod_lpi_time_series_ui <- function(id, spp_menu_title = "Groupe d'espèces"){
  ns <- NS(id)
  tagList(
    fluidRow(
      column(3, 
             shiny::radioButtons(ns("target_taxa"), 
                                 label = spp_menu_title,
                                 choiceValues = c("Tous", "Amphibiens", "Mammifères",
                                                  "Oiseaux", "Poissons", "Reptiles"),
                                 choiceNames = c("Toutes les espèces", "Amphibiens",
                                                 "Mammifères", "Oiseaux", "Poissons", "Reptiles"))
      ),
      column(9,
             shiny::textOutput(outputId = ns("datasummary"))
      )
    ),
    fluidRow(
      shinycssloaders::withSpinner(
      plotly::plotlyOutput(outputId = ns("indextrend"), width = "100%"),
      type = 8,
      color = "#7bb5b1", 
      size = 1
      )
    )
  )
}

#' lpi_time_series Server Functions
#'
#' @noRd
mod_lpi_time_series_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    output$datasummary <- shiny::renderText({
      summarise_index_data(target_taxa = input$target_taxa)
    })
    
    output$indextrend <- plotly::renderPlotly({
      make_indextrend(target_taxa = input$target_taxa)}
      )
  })
}

## To be copied in the UI
# mod_lpi_time_series_ui("lpi_time_series_ui_1")

## To be copied in the server
# mod_lpi_time_series_server("lpi_time_series_ui_1")


#### Test ####

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
