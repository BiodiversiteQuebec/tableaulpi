#' Plot raw time series
#'
#' Plots a raw time series for a clicked population on the point map using \code{ggplot2}. This function can then be used within the \code{timeseries} module to generate the plot on the dashboard in reaction to a click.
#'
#' @param clicked_population Population selected from a user's click on the point map.
#'
#' @import ggplot2 plotly
#' @return A plotly of the raw time series of population size through time, with years on the \code{x} axis and population size on the \code{y} axis. Points are coloured following the same palette as the rest of the dashboard, based on taxa groups, and are linked by lines.
#' @export
#'
#'

make_timeseries <- function(clicked_population){

  # get time series and taxonomic info to observations
  obs <- ratlas::get_timeseries() 
  obs <- obs %>% 
    dplyr::left_join(ratlas::get_gen(endpoint="taxa", 
                                     id = unique(obs$id_taxa)), 
                     by = c("id_taxa" = "id")) %>%
    dplyr::left_join(ratlas::get_datasets(id = unique(obs$id_datasets)),
                     by = c("id_datasets" = "id"))
  obs$id <- as.character(obs$id)
  
  df <- obs[which(obs$id == clicked_population),]

  df_plot <- data.frame(
    "years" = unlist(df$years),
    "values" = unlist(df$values)
    )
  df_plot$hovertemplate <- paste("<b>Année</b>:", df_plot$years, 
                                 "<br><b>Abondance:</b>", df_plot$values)
  
  # plot raw time series
  p <- ggplot2::ggplot(data = df_plot,
                  ggplot2::aes(x = as.integer(years), y = values)) +
    ggplot2::geom_line(col = "#7bb5b1", lwd = 1.5) +
    ggplot2::geom_point(ggplot2::aes(text = hovertemplate), col = "#2e483e", size = 4) +
    ggplot2::labs(x = "",
                  y = "Abondance de la population",
                  title = paste0(
                    "Suivi de la population (",
                    gsub("_", " ", df$scientific_name[1]), ")"
                  )) +
    ggplot2::theme_bw()
                  #" (", df$common_name[1], ")"
  plotly::ggplotly(p, tooltip = "text") %>%
    plotly::config(displayModeBar = FALSE)
}
