#' lpi_time_series UI Function
#'
#' @description A shiny Module to show the LPI trend line plot for a selected taxonomic group, with a loading spinner.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList

mod_lpi_time_series_ui <- function(id, spp_menu_title = "Groupe d'espèces", start_sel = "Tous"){
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
      shiny::textOutput(outputId = ns("datasummary"))
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
                               target_taxa = reactive("tous"))
  }
  shinyApp(ui, server)
}

testapp_lpi_timeseries()
