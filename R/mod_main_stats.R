#' mod_main_stats UI Function
#' 
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_main_stats_ui <- function(id){
  ns <- NS(id)
  tagList(
    shiny::htmlOutput(ns("stats"))
  )
}

#'
#' @param taxa Input choice of taxa to show
#'
mod_main_stats_server <- function(id, taxa){
  moduleServer( id, function(input, output, session){
    
    output$stats <- renderUI({
      
      obs <- tableaulpi::filter_atlas(taxa())
      
      # Make a named list of summary stats
      d <- list(
        "n_sp" = length(unique(obs$id_taxa)),
        "n_pop" = length(unique(obs$id)),
        "mean_tslength" = unlist(lapply(obs$years, length)) %>% mean(na.rm = TRUE) %>% floor()
      )
      
      div(
      stats_card(d$n_pop,'Populations', 'map-marker', 'main-1'),
      stats_card(d$n_sp, 'Espèces', 'bug', 'main-2'),
      stats_card(d$mean_tslength, 'ans par suivi', 'clock', 'main-3'),
      )
    }
    )
  })
}

