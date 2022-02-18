#' view_index UI Function
#'
#' @description A shiny Module creating a title with a help button, followed by a button to open a modal showing the index plots. 
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#' @param text_before_button Title of this module, after which the help button with appear.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_view_index_ui <- function(id, text_before_button){
  ns <- NS(id)
  tagList(
  tags$span(
    # text before the help button. This is the title of the box essentially
    text_before_button, 
            # help button
            tags$sup(shinyWidgets::circleButton(inputId = ns("open_modal"), 
                                                label = "", icon = icon("info"), size = "xs", status = "primary"))),
  # button to open the model with index plots
  # affiche_index is then linked in app_server
  mapselector::mod_modal_observeEvent_ui("affiche_index", button_text = icon("chart-line"))
  )
}

## To be copied in the UI
# mod_view_index_ui("view_index_1")
    
## To be copied in the server
# mod_view_index_server("view_index_1")
