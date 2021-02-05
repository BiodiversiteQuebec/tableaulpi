#' The application User-Interface
#' 
#' @param request Internal parameter for `{shiny}`. 
#'     DO NOT REMOVE.
#' @import shiny
#' @import mapselector
#' @noRd
app_ui <- function(request) {
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    # Your application UI logic 
    mapselector::tableau_de_bord(
      mapselector::dash_title(title = "Indice Planète Vivante"), 
      mapselector::dash_sidebar(
        badge(text_badge = "L'Indice Planète Vivante mesure les changements dans l'abondance des populations animales depuis 1990."),
        radioButtons("taxa", "Choisir le groupe d'espèces", 
                     choiceValues = c("tous", "amphibiens", "mammifères", "oiseaux", "poissons", "reptiles"),
                     choiceNames = c("Toutes les espèces", "Amphibiens", "Mammifères", "Oiseaux", "Poissons", "Reptiles")),
        actionButton("show_index", "Afficher l'indice")
      ),
      mapselector::dash_tabs(
        tab_pointmap(),
        # tab_fulltrend(),
        tab_poptrend(),
        tab_about()
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

