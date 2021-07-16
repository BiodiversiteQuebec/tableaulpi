#' summarise_rawdata UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_summarise_rawdata_ui <- function(id){
  ns <- NS(id)
  tableOutput(ns("summarytable"))
}
    
#' summarise_rawdata Server Functions
#'
#' @noRd 
mod_summarise_rawdata_server <- function(id, clicked_population){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    
    output$summarytable <- renderTable({
      make_summarise_rawdata(clicked_population())
    })
 
  })
}
    
## To be copied in the UI
# mod_summarise_rawdata_ui("summarise_rawdata_ui_1")
    
## To be copied in the server
# mod_summarise_rawdata_server("summarise_rawdata_ui_1")
