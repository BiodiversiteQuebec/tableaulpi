#' timeseries UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_timeseries_ui <- function(id){
  ns <- NS(id)
  tagList(
    div(
    plotly::plotlyOutput(outputId = ns("timeseries"), width = "100%"),
    htmlOutput(ns("blurb"))
    )
  )
}
    
#' timeseries Server Functions
#'
#' @noRd 
mod_timeseries_server <- function(id, clicked_population){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
  
    output$timeseries <- renderPlotly({
      make_timeseries(clicked_population())}
    )
    
    output$blurb <- renderUI({
      
      # get time series and taxonomic info to observations
      obs <- ratlas::get_timeseries() 
      obs <- obs %>% 
        dplyr::left_join(ratlas::get_gen(endpoint="taxa", 
                                         id = unique(obs$id_taxa)), 
                         by = c("id_taxa" = "id")) %>%
        dplyr::left_join(ratlas::get_datasets(id = unique(obs$id_datasets)),
                         by = c("id_datasets" = "id"))
      obs$id <- as.character(obs$id)
      obs <- obs[which(obs$id == clicked_population()),]
      
      # write some context
      tags$div(id = "blurbid", 
               class = "blurbtext",
               tags$h5("Source des données:", obs$owner[1], "(License: ", obs$license[1], ")"),
               tags$h6("Unités d'abondance (de la source originale):", obs$unit[1]),
               tags$p("Chaque point est une mesure de l'abondance de la population à un point dans le temps. L'Indice Planète Vivante se base sur le taux de changement entre ces points pour estimer une tendance moyenne des changements d'abondance de plusieurs populations.")
      )})
  })
}
    
## To be copied in the UI
# mod_timeseries_ui("rawdata_ui_1")
    
## To be copied in the server
# mod_timeseries_server("timeseries_ui_1")
