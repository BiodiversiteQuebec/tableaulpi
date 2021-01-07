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
  #output$map <- leaflet::renderLeaflet(mapselector::make_leaflet_map())
  #mod_modal_make_server("modal_make_ui_1", region = reactive(input$map_shape_click$id))
  
  # "Tendance de l'indice"
  output$indextrend <- plotly::renderPlotly(index_trend_plot(taxa = taxachoice()))
  
  # "À propos de l'indice"
  output$about <- renderText(about_text)
  
}
