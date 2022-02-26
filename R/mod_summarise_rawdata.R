#' summarise_rawdata UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_summarise_rawdata_ui <- function(id){
  ns <- NS(id)
  tagList(
  shiny::htmlOutput(ns("trend_card")),
  shiny::htmlOutput(ns("duration_card"))
  )
}
    
#' summarise_rawdata Server Functions
#'
#' @noRd 
mod_summarise_rawdata_server <- function(id, clicked_population){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    
    # output$status_card <- renderUI({
    #   
    #   # get time series and taxonomic info to observations
    #   obs <- ratlas::get_timeseries() 
    #   obs <- obs %>% 
    #     dplyr::left_join(ratlas::get_gen(endpoint="taxa", 
    #                                      id = unique(obs$id_taxa)), 
    #                      by = c("id_taxa" = "id"))
    #   obs$id <- as.character(obs$id)
    #   obs <- obs[which(obs$id == clicked_population()),]
    # 
    #   # Make a named list of summary stats
    #   status <- if(is.na(obs$qc_status[1])){"Pas de statut"} else{obs$qc_status[1]}
    #   
    #   div(
    #     stats_card(number = status, text = 'Statut (QC)', icon = 'bug', 'main-4')
    #     )
    # }
    # )
    
    # get time series and taxonomic info to observations
    obs <- ratlas::get_timeseries()
    obs <- obs %>%
      dplyr::left_join(ratlas::get_gen(endpoint="taxa",
                                       id = unique(obs$id_taxa)),
                       by = c("id_taxa" = "id"))
    obs$id <- as.character(obs$id)
    
    output$duration_card <- renderUI({
      
      obs <- obs[which(obs$id == clicked_population()),]
      div(stats_card(number = length(obs$years[[1]]), text = 'ans suivis', 'clock', 'main-3'))
    }
    )
    
    output$trend_card <- renderUI({
      obs <- obs[which(obs$id == clicked_population()),]
      
      if(length(obs$years[[1]]) < 6){
        trend_text <- "Pas disponible"
        icon_choice <- "circle-question"
        x <- "-"
      } else {
      
      obs <- tableaulpi::lpi_population(obs)
        
      x = paste0(obs$mean_dt, '%')
      
      if(obs$mean_dt > 5) trend_text <- "En croissance"
      if(obs$mean_dt < -5) trend_text <- "En déclin"
      if(obs$mean_dt > -5 & obs$mean_dt < 5) trend_text <- "Stable"
      
      if(obs$mean_dt > 5) icon_choice <- "arrow-up-right"
      if(obs$mean_dt < -5) icon_choice <- "arrow-down-right"
      if(obs$mean_dt > -5 & obs$mean_dt < 5) icon_choice <- "arrow-right"
      }
      
      div(stats_card(number = x, text = trend_text, icon = icon_choice, 'main-5'))
    })
 
  })
}
    
## To be copied in the UI
# mod_summarise_rawdata_ui("summarise_rawdata_ui_1")
    
## To be copied in the server
# mod_summarise_rawdata_server("summarise_rawdata_ui_1")