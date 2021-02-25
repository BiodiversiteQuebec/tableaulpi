#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @import mapselector
#' @noRd
app_server <- function( input, output, session ) {

  clicked_population <- mapselector::mod_map_select_server(id = "pointmap",
                                                           what_to_click = "marker",
                                                           fun = make_pointmap)
  
  # this is a sort of part-2 to the modal above. it must have the SAME ID or else it won't find the right map
  taxachoice <- mod_subset_plot_leafletproxy_server("pointmap")
  
  
  mapselector::mod_modal_make_server(id = "pop_modal",
                                     region = clicked_population, 
                                     title_format_pattern = "Les données pour la population de %s",
                                     tabPanel("Population trend", span("trend here")))
  
  mapselector::mod_modal_observeEvent_tutorial_server("affiche_tuto",
                                                      title_text = "Cest un tuto",
                                                      md_file = "firstModal.md", 
                                                      second_button = 
                                                      mapselector::mod_modal_observeEvent_ui("affiche_tuto2",
                                                                                             button_text = "Je veux plus d'info"))
  mapselector::mod_modal_observeEvent_tutorial_server("affiche_tuto2",
                                                      title_text = "Guide pour l'interprétation",
                                                      md_file = "second_modal_text.md")
  
  mapselector::mod_modal_observeEvent_tutorial_server("spp_help",
                                         title_text = "Categories d'espece",
                                         md_file = "second_modal_text.md")

  # LPI time series plot
  mod_lpi_time_series_server("lpi", taxachoice =  taxachoice)
  mapselector::mod_modal_observeEvent_server("affiche_index",
                                             title_format_pattern =  "Indice Planète Vivante pour %s",
                                             title_var = taxachoice,
                                             tabPanel(
                                               title = "title",
                                               mod_lpi_time_series_ui("lpi")
                                             ), type = "hidden")

  # "Tendance par population
  mod_population_bubbleplot_server("poptrend", taxachoice = taxachoice)
  # mapselector::mod_modal_observeEvent_server("affiche_poptrend",
  #                                            title_format_pattern =  "Taux de croissance des populations pour %s",
  #                                            title_var = taxachoice,
  #                                            tabPanel(
  #                                              title = "title",
  #                                              mod_population_bubbleplot_ui("population_bubbleplot_ui_1")
  #                                            ), type = "hidden")
  
  # Comparer entre groupes
  mod_ridgeplot_server("mod_ridgeplot_ui_1")
  mapselector::mod_modal_observeEvent_server("affiche_ridgeplot",
                                             title_format_pattern = "Taux de croissance des groupes %s",
                                             title_var = taxachoice,
                                             tabPanel(
                                               title = "title",
                                               mod_ridgeplot_ui("mod_ridgeplot_ui_1")
                                             ), type = "hidden")
  

  # "À propos de l'indice"
  output$about <- renderUI({includeHTML("data/apropos_lpi.html")})

}
