#' subset_plot_leafletproxy UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_subset_plot_leafletproxy_ui <- function(id, spp_menu_title = "Groupe d'espèces", start_sel = "Tous"){
  ns <- NS(id)
  tagList(
    shinyWidgets::radioGroupButtons(ns("taxa"),
                                    label = spp_menu_title,
                                    choiceValues = list("Tous", "Amphibiens", "Mammifères", "Oiseaux", "Poissons", "Reptiles"),
                                    choiceNames = list(HTML("<i class='finature-collection nature-collection-landscape-1'>Tous</i>"),
                                                       HTML("<i class='fianimals animals-010-frog'>Amphibiens</i>"),
                                                       HTML("<i class='fianimals animals-015-squirrel'>Mammifères</i>"),
                                                       HTML("<i class='fianimals animals-020-bird'>Oiseaux</i>"),
                                                       HTML("<i class='finature-collection nature-collection-fish'>Poissons</i>"),
                                                       HTML("<i class='fianimals animals-038-turtle'>Reptiles</i>")),
                                    direction = "vertical",
                                    status = 'primary fibuttons',
                                    selected = start_sel)
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
