# functions needed to calculate the Living Planet Index

# Round number up/down to level of choice
round.choose <- function(x, roundTo = 1, dir = 1) {
  # x = number
  # roundTo = level to round to (1, 5, 10, 100, etc.)
  # direction (0 = up, 1 = down)
  if(dir == 1) {  ##ROUND UP
    x + (roundTo - x %% roundTo)
  } else {
    if(dir == 0) {  ##ROUND DOWN
      x - (x %% roundTo)
    }
  }
}

# function to calculate population growth rate (dt) using the chain method
  # N = vector of population sizes (not transformed)
calc_dt_chain <- function(N){
  
  # calculate population growth rate (chain method)
  dt = c(0) # initial value
  for(i in 2:length(N)){
    dt[i] = log10(N[i]/N[i-1])
  }
  return(dt)
}


# function to compute GAM (following Collen et al. 2009 specifications)
  # df_population: data frame with year_obs column (year of observation) and obs_value_log10 column
  # (log10 transformed population observation (abundance or biomass)) for ONE population
compute_gam <- function(df_population){
  
  # smoothing parameter to be half the number of time points
  smoothParm <- floor(nrow(unique(df_population[,"year_obs"]))/2)
  #print(paste("smoothParm =", smoothParm)) # uncomment if interested in looking at the smoothing param
  
  # run GAM 
  m <- mgcv::gam(obs_value_log10 ~ s(year_obs, k = smoothParm), data = df_population,
                 family = gaussian(), method = "REML")
  return(m)
}

# function to calculate dt from GAM predictions
  # gam.pred_ls: list of predictions from GAMs (one per population)
  # year_pred: vector of years to predict 
get_dt <- function(gam.pred_ls, year_pred){
  
  # extract predicted population size values
  N = gam.pred_ls$fit 
  # assign errors to values for propagation
  N_se = gam.pred_ls$se.fit
  # un-log10
  N = 10^N # un-log
  N_se = 10^N_se
  
  # initialize df to store dts
  dt_df = data.frame(year_pred = year_pred, dt = NA, cilo = NA, cihi = NA)
  for(i in 2:length(N)){
    # calculate dt
    dt = log10(N[i]/N[i-1])
    dt_df[i, "dt"] = dt # save in the table
    # calculate confidence intervals
    dt_df[i, "cilo"] = log10((N[i] - 1.96*N_se[i])/(N[i-1] - 1.96*N_se[i-1]))
    dt_df[i, "cihi"] = log10((N[i] + 1.96*N_se[i])/(N[i-1] + 1.96*N_se[i-1]))
  }
  return("dt" = dt_df)
}


# geometric mean function
gm_mean = function(x, na.rm=TRUE, zero.propagate = FALSE){
  if(any(x < 0, na.rm = TRUE)){
    return(NaN)
  }
  if(zero.propagate){
    if(any(x == 0, na.rm = TRUE)){
      return(0)
    }
    exp(mean(log(x), na.rm = na.rm))
  } else {
    exp(sum(log(x[x > 0]), na.rm=na.rm) / length(x))
  }
}


# function to calculate geometric mean that will be used in bootstrapping
geoMean_boot <- function(dt, i){
  d <- dt[i] # indexing happens here
  avg <- gm_mean(d, na.rm = TRUE)
  return(avg)
}

# function for bootstrap confidence interval 
dt_boot = function(dt){
  # bootstrap resampling
  dt_r = boot::boot(dt, statistic = geoMean_boot, R = 1000)
  # calculate 95% confidence intervals
  dt_ci = boot::boot.ci(dt_r, type = "basic", R = 1000)
  # wrangle into table for output
  dtboot_df = data.frame(gm = dt_ci$t0, 
                         cilo = dt_ci$basic[4], 
                         cihi = dt_ci$basic[5])
  return(dtboot_df)
}

# function to calculate geometric mean growth rate with 95% CI from bootstrapping
dt_gm_group <- function(growthrates_df, groupname){
  
  # get year vector
  year_vec <- sort(unique(growthrates_df$year_pred))
  
  # calculate geometric mean growth rate with 95% CI from bootstrapping
  dt_gm <- list(data.frame(gm = 1, cilo = 1, cihi = 1))
  for(t in 2:length(year_vec)){
    dt_v <- growthrates_df[which(growthrates_df$year_pred == year_vec[t]), "dt"] %>% 
      na.omit() %>% 
      # remove tibble format
      unlist() %>% unname()
    dt_gm[[t]] <- dt_boot(10^dt_v)  
  }
  dt_gm <- bind_rows(dt_gm) %>% log10() 
  dt_gm$year = unique(growthrates_df$year_pred)
  dt_gm$groupid = groupname
  return(dt_gm)
}

# Calculate LPI from population growth rates
calclpi <- function(dt){
  # dt = vector of population growth rates (un-log10 transformed)
  lpi = c(1) # initial value is 1 
  for(i in 2:length(dt)){
    lpi[i] <- lpi[i-1]*dt[i] 
    }
  return(lpi)
}

