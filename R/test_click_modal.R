# test function
testapp_map_click <- function(){
  ui <- fluidPage(
    actionButton("button", "filter me!"),
    mapselector::tab_map(title = "Carte", id = "pointmap",
                         outputFunction = mapselector::mod_map_select_ui),
    
    textOutput(outputId = "clicked")
  )
  
  server <-  function(input, output, session) {
    clicked_population <- mapselector::mod_map_select_server(id = "pointmap",
                                                             what_to_click = "marker",
                                                             fun = make_pointmap,
                                                             taxa = "tous")
    
    output$clicked <- renderText(paste("its a ", clicked_population()))
    
    lpd_qc_test <- filter_lpd_qc("reptiles")
    
    leaflet::leafletProxy("pointmap-map", data = lpd_qc_test) %>% 
      leaflet::clearShapes() %>% 
      leaflet::addCircleMarkers(
        data = lpd_qc_test,
        layerId = lpd_qc_test[["scientific_name"]],
        label = lpd_qc_test[["scientific_name"]],
        color = "#99999",
        stroke = FALSE,
        fillOpacity = .7,
        radius = 5
      ) 

  }
  shinyApp(ui, server)
}


options(shiny.reactlog=TRUE)
testapp_map_click()
