#' Plot raw time series
#'
#' Plots a raw time series for a clicked population on the point map using \code{ggplot2}. This function can then be used within the \code{timeseries} module to generate the plot on the dashboard in reaction to a click.
#'
#' @param clicked_population Population selected from a user's click on the point map.
#'
#' @import ggplot2
#' @return A plot of the raw time series of population size through time, with years on the \code{x} axis and population size on the \code{y} axis. Points are coloured following the same palette as the rest of the dashboard, based on taxa groups, and are linked by lines.
#' @export
#'
#'

make_timeseries <- function(clicked_population){

  ## colour palette ##
  pal <- c("Amphibiens" = "#56B4E9",
           "Mammifères" = "#D55E00",
           "Oiseaux" = "#E69F00",
           "Poissons" = "#0072B2",
           "Reptiles" = "#009E73",
           "#999999")

  # import dataset
  obs <- dplyr::left_join(ratlas::get_timeseries(),
                          ratlas::get_gen(endpoint="taxa"),
                          by = c("id_taxa" = "id"))
  obs$id <- as.character(obs$id)

  df <- obs[which(obs$id == clicked_population),]

  df_plot <- data.frame(
    "years" = unlist(df$years),
    "values" = unlist(df$values)
    )

  # make axis breaks
  # round to integer, since the x axis is years
  if(nrow(df_plot) <= 10){
    x_breaks = seq(min(df_plot$years), max(df_plot$years), by = 1)
  } else{
    x_breaks = seq(min(df_plot$years), max(df_plot$years), by = 5)
  }

  # plot raw time series
  ggplot2::ggplot(data = df_plot,
                  ggplot2::aes(x = years, y = values)) +
    ggplot2::geom_line(col = "#4d4d4d") +
    ggplot2::geom_point(col = pal[df$species_gr[1]],
                        size = 4) +
    ggplot2::scale_color_manual(values = pal) +  # use palette from above
    ggplot2::scale_x_continuous(breaks = x_breaks) +
    ggplot2::labs(x = "",
                  y = "Abondance de la population",
                  title = paste0(
                    "Suivi de la population choisie (",
                    gsub("_", " ", df$scientific_name[1]), ")"
                  )
                  #" (", df$common_name[1], ")"
    ) +
    tableaulpi::theme_mapselector()
}
