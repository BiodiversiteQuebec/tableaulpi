# test function
testapp_map_click <- function(){
  ui <- fluidPage(
    
    mod_subset_plot_leafletproxy_ui("pointmap"),
    
    
    mapselector::tab_map(title = "Carte", id = "pointmap",
                         outputFunction = mapselector::mod_map_select_ui),
    
    textOutput(outputId = "clicked"),
    textOutput(outputId = "grp")
  )
  
  server <-  function(input, output, session) {
    clicked_population <- mapselector::mod_map_select_server(id = "pointmap",
                                                             what_to_click = "marker",
                                                             fun = make_pointmap,
                                                             taxa = "tous")
    
    output$clicked <- renderText(paste("its a ", clicked_population()))
    
#
    group_selected <- mod_subset_plot_leafletproxy_server("pointmap")
    
    output$grp <- renderText(paste("Looks like they want to see only ", group_selected()))

  }
  shinyApp(ui, server)
}


options(shiny.reactlog=TRUE)
testapp_map_click()
