#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @import mapselector
#' @noRd
app_ui <- function(request) {

  tagList(

    # information panel that slides onto window (appears on hover)
    mapselector::marcel(filename = "firstModal.md"),

    # Leave this function for adding external resources
    golem_add_external_resources(),


    # Application UI logic -----------------------------------------------------


    # Standard mapselector dashboard format ----

    mapselector::tableau_de_bord(
      mapselector::dash_title(title = "Indice Planète Vivante"),
      mapselector::dash_sidebar(
        badge(text_badge = "L'Indice Planète Vivante mesure les changements dans l'abondance des populations animales depuis 1990."),
        mod_subset_plot_leafletproxy_ui(
          "pointmap",
          mapselector::mod_modal_helpbutton_ui(id = "spp_help",
                                               "Choisir le groupe d'espèces")
        ),



        # Modals that appear when a button is clicked ----

        # Index trend through time
        mapselector::mod_modal_observeEvent_ui("affiche_index", button_text = "Afficher l'IPV"),

        # Density plot showing the distributions of index values per group
        mapselector::mod_modal_observeEvent_ui("affiche_ridgeplot", button_text = "IPV par groupe"),

        # Point plot showing individual populations' trends
        mapselector::mod_modal_observeEvent_ui("affiche_poptrend", button_text = "IPV par population"),

        # Pop-up information box
        mapselector::mod_modal_observeEvent_ui("affiche_tuto", button_text = "Guide d'utilisation")
      ),


      # Tabs that appear on the main dashboard ----
      mapselector::dash_tabs(


        # First tab: Map on landing page
        #maybe a little strange, but here we pass in the UI of a modal and the id that defines it.
        mapselector::tab_map(title = "Carte", id = "pointmap",
                             outputFunction = mapselector::mod_map_select_ui),
        # mapselector::tab_map(title = "Tendance par population",
        #         outputFunction = mod_population_bubbleplot_ui,
        #         id = "poptrend"),


        # Second tab: more detailed information about the index
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
