#' subset_plot_leafletproxy UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_subset_plot_leafletproxy_ui <- function(id, spp_menu_title = "groupe d'espèces"){
  ns <- NS(id)
  tagList(
    radioButtons(ns("taxa"), label = spp_menu_title,
                 choiceValues = c("tous", "amphibiens", "mammifères",
                                  "oiseaux", "poissons", "reptiles"),
                 choiceNames = c("Toutes les espèces", "Amphibiens", 
                                 "Mammifères", "Oiseaux", "Poissons", "Reptiles"))
  )
}
    
#' subset_plot_leafletproxy Server Functions
#'
#' @noRd 
mod_subset_plot_leafletproxy_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
 
    observe({
      filter_leaflet_map(NS(id, "map"), taxa_to_show = input$taxa)
    })
    
    return(reactive(input$taxa))
  })
}
    
## To be copied in the UI
# mod_subset_plot_leafletproxy_ui("subset_plot_leafletproxy_ui_1")
    
## To be copied in the server
# mod_subset_plot_leafletproxy_server("subset_plot_leafletproxy_ui_1")
