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
  #mod_modal_make_server("modal_make_ui_1", region = reactive(input$map_shape_click$id))
  
  # Small intro to dashboard
  mod_tuto_modal_server("tuto_modal_ui_1")
  observeEvent(input$pass, {
    removeModal()
  })
  observeEvent(input$next1, {
    mod_tuto_modal2_server("tuto_modal2_ui_1")
  })
  
  # "Tendance de l'indice" en module
  # Sidebar menu choices of species
  observeEvent(input$taxa, {
    mod_lpi_time_series_server("lpi_time_series_ui_1", taxachoice)
  })
  # Show plot in modal
  observeEvent(input$show_index, {
    showModal(
      modalDialog(
        mod_lpi_time_series_ui("lpi_time_series_ui_1"),
        title = "Indice Planète Vivante",
        size = "l"
      )
    )
  })
  
  # "Tendance par population
  output$poptrend <- plotly::renderPlotly(make_poptrend(taxa = taxachoice()))
  
  # "À propos de l'indice"
  output$about <- renderUI({includeHTML("data/apropos_lpi.html")})

}
