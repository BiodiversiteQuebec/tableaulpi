# Function to plot the raw time series for a clicked population on the point map

#' @import ggplot2

make_timeseries <- function(clicked_population){

  # add palette from the map here (for now... this is to improve) ----
  pal <- c("amphibiens" = "#56B4E9",
           "mammifères" = "#D55E00", 
           "oiseaux" = "#E69F00", 
           "poissons" = "#0072B2", 
           "reptiles" = "#009E73",
           "#999999") # will need invertebrate colour here when survol is added ----
  
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
