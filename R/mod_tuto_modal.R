#' tuto_modal UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_tuto_modal_ui <- function(id){
  ns <- NS(id)
  tagList(
 
  )
}
    
#' tuto_modal Server Functions
#'
#' @noRd 
mod_tuto_modal_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    showModal(
      modalDialog(
        includeHTML(
          rmarkdown::render("data-raw/firstModal.Rmd", output_dir = "data", quiet = TRUE)
        ),
        # easyClose = FALSE,
        footer = tagList(
          span(
            modalButton("Passer l'introduction"),
            style = "position:relative; float:left;"
          ),
          actionButton("next1", "Suivant")
        )#,
        # size = "l"
      )
    )
  })
}

    
## To be copied in the UI
# mod_tuto_modal_ui("tuto_modal_ui_1")
    
## To be copied in the server
# mod_tuto_modal_server("tuto_modal_ui_1")


# same as the other .. no need to rewrite it!! 
#' @export
mod_modal_observeEvent_ui <- function(id, button_text, ...){
  ns <- NS(id)
  actionButton(ns("open_modal"), button_text, ...)
}

#' modal_make Server Functions
#'



nextPage <- function(id, i) {
  actionButton(NS(id, paste0("go_", i, "_", i + 1)), "next")
}

wrapPage <- function(title, page, button_right = NULL) {
  tabPanel(
    title = title, 
    fluidRow(
      column(12, page)
    ), 
    fluidRow(
      column(6, button_left),
      column(6, button_right)
    )
  )
}

# need to take a list of markdown pages, catch dots in list
# give each a modal button 
# and recurse for the next button each time.