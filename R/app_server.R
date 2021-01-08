#' The application server-side
#' 
#' @param input,output,session Internal parameters for {shiny}. 
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function( input, output, session ) {
  
  # get taxa choice input
  taxachoice <- reactive({toString(input$taxa)})
  
  # Map 
  output$pointmap <- leaflet::renderLeaflet(make_pointmap())
  #mod_modal_make_server("modal_make_ui_1", region = reactive(input$map_shape_click$id))
  
  # "Tendance de l'indice"
  output$indextrend <- plotly::renderPlotly(make_indextrend(taxa = taxachoice()))
  
  # "Tendance par population
  output$poptrend <- plotly::renderPlotly(make_poptrend(taxa = taxachoice()))
  
  # "À propos de l'indice"
  output$about <- renderUI({includeHTML("data/apropos_lpi.html")})

}
