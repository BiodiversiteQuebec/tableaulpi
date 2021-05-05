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

  # add palette from the map here (for now... this is to improve) ----
  pal <- c("amphibiens" = "#56B4E9",
           "mammifères" = "#D55E00", 
           "oiseaux" = "#E69F00", 
           "poissons" = "#0072B2", 
           "reptiles" = "#009E73",
           "#999999")
  
  # import dataset
  df <- readRDS("data/lpd_qc_fake.RDS")
  df <- df[which(df$org_event == clicked_population),]
  group_name <- df$taxa[1]
  
  # plot raw time series
  ggplot(df, 
         aes(x = year_obs, 
                 y = obs_value)) +
    geom_line(col = "#4d4d4d") +
    geom_point(col = pal[group_name], 
               size = 4) +
    scale_color_manual(values = pal) +  # use palette from above
    scale_x_continuous(breaks = function(x) seq(ceiling(x[1]), floor(x[2]), by = 1)) + # round to integer, since the x axis is years
    labs(x = "",
         y = "Abondance de la population",
         caption = paste0("Source des données: ", 
                          unique(df$intellectual_rights))) +
    theme_mapselector()
}
