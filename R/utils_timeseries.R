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
  # set api token as environment variable
  Sys.setenv("ATLAS_API_TOKEN" = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoicmVhZF9vbmx5X2FsbCIsIm1haWwiOiJrYXRoZXJpbmUuaGViZXJ0QHVzaGVyYnJvb2tlLmNhIn0.jHfCLsRseU0--5qFB5A_PfIOEv0I24PQw1ip3q_3KQw')
  
  # get time series and taxonomic info to observations
  obs <- dplyr::left_join(ratlas::get_timeseries(), 
                          ratlas::get_gen(endpoint="taxa"), 
                          by = c("id_taxa" = "id"))
  obs$id <- as.character(obs$id)
  
  df <- obs[which(obs$id == clicked_population),]
  
  df_plot <- data.frame(
    "years" = unlist(df$years), 
    "values" = unlist(df$values)
    )
  
  # plot raw time series
  ggplot(data = df_plot,
         aes(x = years, y = values)) +
    geom_line(col = "#4d4d4d") +
    geom_point(col = pal[df$species_gr[1]], 
               size = 4) +
    scale_color_manual(values = pal) +  # use palette from above
    scale_x_continuous(breaks = function(x) seq(ceiling(x[1]), floor(x[2]), by = 1)) + # round to integer, since the x axis is years
    labs(x = "",
         y = "Abondance de la population",
         title = paste0(
           gsub("_", " ", df$scientific_name[1])#, 
           #" (", df$common_name[1], ")"
           )#,
         # caption = paste0("Source des données: ", 
         #                  unique(df$intellectual_rights))
         ) +
    theme_mapselector()
}
