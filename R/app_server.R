#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @import mapselector
#' @import ratlas
#' @import dplyr
#' @noRd

app_server <- function( input, output, session ) {

  # Stores scientific name of population that was clicked on the point map
  clicked_population <- mapselector::mod_map_select_server(id = "pointmap",
                                                           what_to_click = "marker",
                                                           fun = make_pointmap)
  # this is a sort of part-2 to the modal above. it must have the SAME ID or else it won't find the right map
  taxachoice <- mod_subset_plot_leafletproxy_server("pointmap")
  
  # show summary statistics on the landing page
  mod_map_summarytable_server("map_summarytable_1", taxa = taxachoice)
  
  # Plot raw time series of clicked population in a pop-up modal ----
  
  mod_timeseries_server("timeseries_ui_1", clicked_population)
  mod_species_photo_server("species_photo_ui_1", clicked_population)
  mod_summarise_rawdata_server("summarise_rawdata_ui_1", clicked_population)
  mapselector::mod_modal_make_server(id = "pop_modal",
                                     region = clicked_population, 
                                     title_format_pattern = "Les données pour Population %s",
                                     tabPanel("Données brutes", 
                                              fluidRow(
                                                column(4, 
                                                       mod_species_photo_ui("species_photo_ui_1"),
                                                       mod_summarise_rawdata_ui("summarise_rawdata_ui_1")
                                                       ),
                                                column(8,
                                                       mod_timeseries_ui("timeseries_ui_1")
                                                       )
                                              )
                                     )
  )
  
  
  # Show tutorial information in various modals ----
  
  mapselector::mod_modal_observeEvent_tutorial_server("affiche_tuto",
                                                      title_text = "Que mesure l'Indice Planète Vivante?",
                                                      md_file = "firstModal.md", 
                                                      second_button = 
                                                      mapselector::mod_modal_observeEvent_ui("affiche_tuto2",
                                                                                             button_text = "Plus d'informations"))
  mapselector::mod_modal_observeEvent_tutorial_server("lpi_help",
                                                      title_text = "Guide d'interprétation de l'Indice Planète Vivante",
                                                      md_file = "second_modal_text.md")
  
  mapselector::mod_modal_observeEvent_tutorial_server("spp_help",
                                         title_text = "Catégories d'espèces",
                                         md_file = "second_modal_text.md")

  
  # Show index plots in a modal with tabs ----
  
  mod_lpi_time_series_server("lpi")
  mod_population_bubbleplot_server("poptrend")
  mod_ridgeplot_server("mod_ridgeplot_ui_1")
  
  mapselector::mod_modal_observeEvent_server(
    "affiche_index",
    title_format_pattern =  "Indice Planète Vivante: %s",
    title_var = taxachoice,
    # Plot the index trend through time, by selected taxa group ----
    tabPanel(
      title = "Tendance moyenne",
      mod_lpi_time_series_ui("lpi")
    ), 
    # Plot of distribution of growth rates by group
    tabPanel(
      title = "Distribution des tendances",
      mod_ridgeplot_ui("mod_ridgeplot_ui_1")
      ),
    # Plot of growth rates of each population
    tabPanel(
      title = "IPV par population",
      mod_population_bubbleplot_ui("poptrend")
      ))

  # Include more detailed html content (text, plots, etc.) about the index
  
  output$about <- renderUI({includeHTML("data/apropos_lpi.html")})

}
