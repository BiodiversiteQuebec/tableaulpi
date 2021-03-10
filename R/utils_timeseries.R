# Function to plot the raw time series for a clicked population on the point map

#' @import ggplot2

make_timeseries <- function(clicked_population){

  df <- readRDS("data/lpd_qc_fake.RDS")
  df <- df[which(df$scientific_name == clicked_population),]
  
  ggplot(df, aes(x = year_obs, y = obs_value)) +
    geom_line() +
    labs(x = "",
         y = "Abondance de la population") +
    theme_classic()
}
