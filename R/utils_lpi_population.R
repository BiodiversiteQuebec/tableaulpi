#' Calculate log-ratio growth rates and LPI trend at the population level
#' 
#' Calculates the log-ratio change in raw population abundances for each population time series in the obs dataframe and calculates the (LPI) index values for the time series.
#'
#' @param x Data frame of Atlas observations table joined with taxa table.
#'
#' @return Data frame 'x' with new columns \code{dt} which holds a list of log-ratio growth rates, \code{mean_dt} which holds the arithmetic mean log-ratio growth rate for the time series, and \code{lpi} which holds a list of index values calculated from the growth rates (dt).
#' @export
#' 

lpi_population <- function(x){
  
  N <- unlist(x$values[[1]])
  
  # only apply to time series with at least 6 time points
  if(length(N) >= 6){
    
    # calculate population growth rate (chain method)
    dt = c(0) # initial value
    for(i in 2:length(N)){
      dt[i] = log10(N[i]/N[i-1])
    }
    
    x$dt <- list(dt)
#    x$cumulative_dt <- sum(dt[-1], na.rm = TRUE)*100
    x$mean_dt <- round(mean(dt[-1], na.rm = TRUE)*100, digits = 1)
    
    # calculate index value
    lpi = c(1) # initial value is 1 
    for(i in 2:length(dt)){
      lpi[i] <- lpi[i-1]*10^dt[i] }
    
    x$lpi <- list(lpi)
#    x$lpi_final <- tail(lpi, n = 1)
  }
  return(x)
}
