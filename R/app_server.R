#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function( input, output, session ) {

  # Set reactive values
  taxachoice <- reactive({toString(input$taxa)})

  # Map
  output$pointmap <- leaflet::renderLeaflet(make_pointmap(taxa = taxachoice()))

  # Small intro to dashboard
  mapselector::mod_modal_observeEvent_tutorial_server("affiche_tuto",
                                         title_text = "Cest un tuto",
                                         md_file = "data-raw/firstModal.md", 
                                         second_button = 
                                           mapselector::mod_modal_observeEvent_ui("affiche_tuto2",
                                                                                  button_text = "Je veux plus d'info"))
 
  mapselector::mod_modal_observeEvent_tutorial_server("affiche_tuto2",
                                         title_text = "Guide pour l'interprétation",
                                         md_file = here::here("inst", "app", "www", "second_modal_text.md"))

  mod_lpi_time_series_server("lpi", taxachoice =  taxachoice)

  mapselector::mod_modal_observeEvent_server("affiche_index",
                                             title_format_pattern =  "Indice Planète Vivante pour %s",
                                             title_var = taxachoice,
                                             tabPanel(
                                               title = "title",
                                               mod_lpi_time_series_ui("lpi")
                                             ), type = "hidden")

  # "Tendance par population
  output$poptrend <- plotly::renderPlotly(make_poptrend(taxa = taxachoice()))

  # "À propos de l'indice"
  output$about <- renderUI({includeHTML("data/apropos_lpi.html")})

}


# TODO contrast reactivelog with and without the tuto modals
