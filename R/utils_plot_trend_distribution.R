#' trend_distribution of the density of population growth rates per taxa
#'
#' @import ggplot2 dplyr ratlas
#' @return A plotly barchart showing the trend distribution of the density of all population growth rates for each taxa, stacked vertically to allow comparison between groups. The plot is themed with \code{theme_mapselector()}.
#' @export
#'
#'
make_trend_distribution <- function(target_year){

  # read ratlas data
  obs <- dplyr::left_join(ratlas::get_timeseries(),
                          ratlas::get_gen(endpoint="taxa"),
                          by = c("id_taxa" = "id"))

  # split into list per series to calculate log-ratio index for each population
  obs <- dplyr::group_split(obs, by = as.factor(id)) %>%
    lapply(tableaulpi::lpi_population) %>%
    dplyr::bind_rows() # rebind together
  obs$mean_dt[is.infinite(obs$mean_dt)] <- NA

  # remove first entry of each time series
  # (the first dt is set to 0 and first lpi is set to 1 automatically, so is uninformative)
  obs$years <- lapply(obs$years, function(x) x <- x[-1])
  obs$values <- lapply(obs$values, function(x) x <- x[-1])
  obs$dt <- lapply(obs$dt, function(x) x <- x[-1])
  obs$lpi <- lapply(obs$lpi, function(x) x <- x[-1])

  # break dataset into 1 row per year and lpi value
  obs <- tidyr::unnest(obs, cols = c(dt, years, lpi))

  # Classify trends based on growth rate
  obs$trend <- "Pas disponible"
  obs$trend[which(obs$lpi > 1.05)] <- "Croissance"
  obs$trend[which(obs$lpi <= 1.05 & obs$lpi >= 0.95)] <- "Stable"
  obs$trend[which(obs$lpi < 0.95)] <- "Déclin"
  obs$trend <- factor(obs$trend, levels = c("Pas disponible", "Déclin", "Stable", "Croissance"))

  # set species_gr as factor so it always shows on the plot
  obs$species_gr <- factor(obs$species_gr, levels = c("Amphibiens", "Mammifères", "Oiseaux", "Poissons", "Reptiles"))

  # filter dataset by selected years
  obs <- obs[which(obs$years >= target_year[1] & obs$years <= target_year[2]),]

  # calculate frequency of each trend status
  data <- obs %>%
    dplyr::group_by(species_gr) %>%
    dplyr::count(trend)
  # add text label to show in plotly
  data$hovertext <- paste0(data$n, " populations")

  # make plot in ggplot
  p <- ggplot2::ggplot(data = data) +
    ggplot2::geom_bar(ggplot2::aes(y = species_gr, x = n,
                                   fill = trend,
                                   text = hovertext),
                      position = "fill",
                      stat = "identity") +
    ggplot2::labs(x = "", y = "", fill = "Tendance") +
    ggplot2::theme_bw() +
    ggplot2::scale_fill_manual(labels = c("Pas disponible", "Déclin", "Stable", "Croissance"),
                               breaks = c("Pas disponible", "Déclin", "Stable", "Croissance"),
                               values = rev(c("#1a9850", "#d9ef8b", "#d73027", "grey"))) +
    ggplot2::theme(legend.position = "top") +
    ggplot2::scale_x_continuous(labels = function(x) paste0(100*x, "%")) # Add percent sign
  # convert to plotly
  (pp <- plotly::ggplotly(p, tooltip = c("text")))
}
