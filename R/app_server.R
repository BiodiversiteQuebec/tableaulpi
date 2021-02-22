#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @import mapselector
#' @noRd
app_server <- function( input, output, session ) {

  # Set reactive values
  taxachoice <- reactive({toString(input$taxa)})

  # Map
  output$pointmap <- leaflet::renderLeaflet(make_pointmap(taxa = taxachoice()))
 
  mapselector::mod_modal_observeEvent_tutorial_server("spp_help",
                                         title_text = "Categories d'espece",
                                         md_file = "second_modal_text.md")

  # LPI time series plot
  mod_lpi_time_series_server("lpi", taxachoice =  taxachoice)
  mapselector::mod_modal_observeEvent_server("affiche_index",
                                             title_format_pattern =  "Indice Planète Vivante pour %s",
                                             title_var = taxachoice,
                                             tabPanel(
                                               title = "title",
                                               mod_lpi_time_series_ui("lpi")
                                             ), type = "hidden")

  # "Tendance par population
  mod_population_bubbleplot_server("population_bubbleplot_ui_1", taxachoice = taxachoice)
  mapselector::mod_modal_observeEvent_server("affiche_poptrend",
                                             title_format_pattern =  "Taux de croissance des populations pour %s",
                                             title_var = taxachoice,
                                             tabPanel(
                                               title = "title",
                                               mod_population_bubbleplot_ui("population_bubbleplot_ui_1")
                                             ), type = "hidden")
  
  # Comparer entre groupes
  mod_ridgeplot_server("mod_ridgeplot_ui_1")
  mapselector::mod_modal_observeEvent_server("affiche_ridgeplot",
                                             title_format_pattern = "Taux de croissance des groupes %s",
                                             title_var = taxachoice,
                                             tabPanel(
                                               title = "title",
                                               mod_ridgeplot_ui("mod_ridgeplot_ui_1")
                                             ), type = "hidden")
  

  # "À propos de l'indice"
  output$about <- renderUI({includeHTML("data/apropos_lpi.html")})

}


# TODO contrast reactivelog with and without the tuto modals
