#' Ridgeplot of the density of population growth rates per taxa
#'
#' @import ggplot2 ggridges dplyr
#' @return A ridgeplot of the density of all population growth rates for each taxa, stacked vertically to allow comparison between groups. The plot is themed with \code{theme_mapselector()}.
#' @export
#'
#'
make_ridgeplot <- function(){

  #selected_years <- as.integer(target_year)
  
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
  obs$dt <- lapply(obs$dt, function(x) x <- x[-1])
  obs$lpi <- lapply(obs$lpi, function(x) x <- x[-1])
  
  obs <- tidyr::unnest(obs, cols = c(dt, years, lpi))
  
  # filter year of choice
  #obs <- dplyr::filter(obs, years >= selected_years[1] & years <= selected_years[2])

  # Classify trends based on growth rate
  obs$trend <- "Pas disponible"
  obs$trend[which(obs$lpi > 1.05)] <- "Croissance"
  obs$trend[which(obs$lpi <= 1.05 & obs$lpi >= 0.95)] <- "Stable"
  obs$trend[which(obs$lpi < 0.95)] <- "Déclin"
  obs$trend <- factor(obs$trend, levels = c("Pas disponible", "Déclin", "Stable", "Croissance"))

  # calculate frequency of each trend status
  data <- obs %>% dplyr::group_by(species_gr, trend) %>% 
    dplyr::count()
  # # count points per species group
  # temp <- obs %>% dplyr::group_by(species_gr) %>% dplyr::count()
  # data <- dplyr::left_join(data, temp)
  # # calculate percentage
  # data$Déclin_p <- 100*(data$Déclin/data$n)
  # data$Stable_p <- 100*(data$Stable/data$n)
  # data$Croissance_p <- 100*(data$Croissance/data$n)
  
  p <- ggplot2::ggplot(data = data) +
    ggplot2::geom_bar(ggplot2::aes(y = species_gr, x = n, fill = trend),
                      position = "fill", stat = "identity") +
    ggplot2::labs(x = "", y = "", fill = "Tendance") +
    tableaulpi::theme_mapselector() +
    ggplot2::scale_fill_manual(values = rev(c("#1a9850", "#d9ef8b", "#d73027", "grey"))) +
    ggplot2::scale_x_continuous(labels = function(x) paste0(100*x, "%")) + # Add percent sign
    ggplot2::theme(legend.position = "top")

  pp <- plotly::ggplotly(p, tooltip = c("x"))
  
  # fig <- plotly::plot_ly(data, x = ~Déclin_p, y = ~species_gr, 
  #                type = 'bar', orientation = 'h', 
  #                name = 'Déclin',
  #                marker = list(color = '#d73027',
  #                              line = list(color = '#d73027', width = 1)),
  #                hovertemplate = paste("%{x:1}%<extra></extra>"))
  # fig <- fig %>% plotly::add_trace(x = ~Stable_p, name = 'Stable',
  #                          marker = list(color = '#d9ef8b',
  #                                        line = list(color = '#d9ef8b',
  #                                                    width = 1)))
  # fig <- fig %>% plotly::add_trace(x = ~Croissance_p, name = 'Croissance',
  #                          marker = list(color = '#1a9850',
  #                                        line = list(color = '#1a9850',
  #                                                    width = 1)))
  # fig <- fig %>% plotly::layout(barmode = 'stack',
  #                       xaxis = list(title = ""),
  #                       yaxis = list(title = ""))
  # fig
  # 
  return(pp)
}
