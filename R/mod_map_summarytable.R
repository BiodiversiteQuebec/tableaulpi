#' mod_map_summarytable UI Function
#'
#' @description A shiny Module to show summary statistics about the data shown on the map.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 

mod_map_summarytable_ui <- function(id){
  ns <- NS(id)
  tagList(
    shiny::tableOutput(ns("summary_table"))
  )
}
    
#' map_summarytable Server Functions
#'
#' @noRd 
mod_map_summarytable_server <- function(id, taxa){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    output$summary_table <- shiny::renderTable({
      make_map_summarytable(taxa()) 
    })
 
  })
}
    
## To be copied in the UI
# mod_map_summarytable_ui("map_summarytable_1")
    
## To be copied in the server
# mod_map_summarytable_server("map_summarytable_1")



#### Test ####

testapp_map_summarytable <- function(){
  ui <- fluidPage(
    mod_map_summarytable_ui("test")
  )
  
  server <-  function(input, output, session) {
    
    mod_map_summarytable_server("test", taxa = reactive("Oiseaux"))
  }
  shinyApp(ui, server)
}

testapp_map_summarytable()