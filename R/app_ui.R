#' The application User-Interface
#' 
#' @param request Internal parameter for `{shiny}`. 
#'     DO NOT REMOVE.
#' @import shiny
#' @import mapselector
#' @noRd
app_ui <- function(request) {
  tagList(
    mapselector::marcel(filename = "firstModal.md"),
    # Leave this function for adding external resources
    golem_add_external_resources(),
    # Your application UI logic 
    mapselector::tableau_de_bord(
      mapselector::dash_title(title = "Indice Planète Vivante"), 
      mapselector::dash_sidebar(
        badge(text_badge = "L'Indice Planète Vivante mesure les changements dans l'abondance des populations animales depuis 1990."),
        mod_subset_plot_leafletproxy_ui(
          "pointmap", 
          mapselector::mod_modal_helpbutton_ui(id = "spp_help",
                                               "Choisir le groupe d'espèces")
        ),
        mapselector::mod_modal_observeEvent_ui("affiche_index", button_text = "Afficher l'IPV"),
        mapselector::mod_modal_observeEvent_ui("affiche_ridgeplot", button_text = "IPV par groupe"),
        mapselector::mod_modal_observeEvent_ui("affiche_poptrend", button_text = "IPV par population"),
        mapselector::mod_modal_observeEvent_ui("affiche_tuto", button_text = "Guide d'utilisation")
      ),
      mapselector::dash_tabs(
        #maybe a little strange, but here we pass in the UI of a modal and the id that defines it.
        mapselector::tab_map(title = "Carte", id = "pointmap",
                             outputFunction = mapselector::mod_map_select_ui),
        mapselector::tab_gen(title = "À propos de l'indice", 
                outputFunction = htmlOutput, 
                id = "about")
      )
    )
  )
}

#' Add external Resources to the Application
#' 
#' This function is internally used to add external 
#' resources inside the Shiny application. 
#' 
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function(){
  
  add_resource_path(
    'www', app_sys('app/www')
  )
 
  tags$head(
    favicon(ext = 'png'),
    bundle_resources(
      path = app_sys('app/www'),
      app_title = 'IPVQuébec'
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert() 
  )
}

