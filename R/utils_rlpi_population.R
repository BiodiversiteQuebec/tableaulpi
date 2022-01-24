#' Calculate LPI trend at the population level from rlpi outputs
#' 
#' Used to plot population trends behind the mean LPI index trend, to communicate uncertainty.
#'
#'
#' @param target_taxa 
#'
#' @return Data frame containing years, LPI_final value, and population_id.
#' 
#' @import tidyr here
#' @export

make_rlpi_population <- function(target_taxa){
  
  # read growth rates generated with rlpi
  poplambda <- read.csv(paste0(here::here("data/rlpi/"), target_taxa, "_pops_PopLambda.txt"), na.strings="-1")
  
  # convert these to LPI values (per population, rather than from a mean growth rate)
  poplpi <- apply(poplambda[,-1], 1, function(x){
    
    if(sum(x, na.rm = TRUE) != 1){
      
      # calculate index value
      lpi = c(1) # initial value is 1 
      for(i in 2:length(x)){
        lpi[i] <- lpi[i-1]*10^x[i] 
      }
      x <- lpi
    }
    return(x)
  }) %>% t() %>% as.data.frame()
  
  # assign population ids and years
  colnames(poplpi) <- colnames(poplambda)[-1]
  poplpi$population_id <- poplambda$population_id
  
  # convert to long format for plotting
  poplpi <- poplpi %>% 
    tidyr::pivot_longer(1:(ncol(poplpi)-1),
                        values_to = "LPI_final", 
                        names_to = "years", 
                        names_prefix = "X") %>%
    na.omit()
  poplpi$years <- as.numeric(poplpi$years)
  return(poplpi)
}
