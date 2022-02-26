#' species_photo UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_species_photo_ui <- function(id){
  ns <- NS(id)
  htmlOutput(ns("photo"))
}
    
#' species_photo Server Functions
#'
#' @noRd 
mod_species_photo_server <- function(id, clicked_population){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
 
    output$photo <- renderUI({
      
     x <- make_species_photo(clicked_population())
     photo <- x$photo
      
      div(style=list('float:left'),
          photo_card(photo$thumb_url, x$sp_name, x$species_gr, photo$url)
      )
    })
    
  })
}
    
## To be copied in the UI
# mod_species_photo_ui("species_photo_ui_1")
    
## To be copied in the server
# mod_species_photo_server("species_photo_ui_1")
