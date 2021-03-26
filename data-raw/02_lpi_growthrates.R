# Script to calculate the (unweighted) Living Planet Index for Quebec 
# from the Living Planet Database

# load libraries
require(tidyr)
require(dplyr)
require(mgcv)
require(sf)

# load functions
source("data-raw/00_lpi_functions.R")

# time period for which the indicator is being calculated
year_pred <- data.frame("year_obs" = 1990:2018)

# import data ------------------------------------------------------------------
df <- readRDS("data/lpd_qc_fake.RDS")

# log10-transform population sizes
df = mutate(df, obs_value_log10 = log10(obs_value))
df = sf::st_drop_geometry(df)

# triage of populations by time series length ----------------------------------

# 1. get time series length
duration_df = df %>% group_by(id_datasets, org_event, scientific_name) %>%
  summarise(duration = max(year_obs) - min(year_obs),
            steps = length(unique(year_obs))) 

# 2a. identify populations to be analyzed with chain method (< 6 steps)

chain = duration_df$org_event[which(duration_df$steps < 6 & duration_df$steps >= 2)]
# extract datasets to analyze with chain method
df_chain = df[which(df$org_event %in% chain),]

# 2b. select populations to analyze with GAM method (>= 6 time steps)

gam = duration_df$org_event[which(duration_df$steps >= 6 & duration_df$duration >= 6)]
# extract datasets to analyze with GAM method
df_gam = df[which(df$org_event %in% gam),]

# chain method -----------------------------------------------------------------

# calculate growth rates (dt) using the chain method 
dt_chain = df_chain %>%
  group_by(id_datasets, org_event, scientific_name) %>%
  mutate(dt = calc_dt_chain(obs_value))

# GAM method -------------------------------------------------------------------

# split into list of individual population time series
df_gam_ls = group_split(df_gam, id_datasets, org_event, scientific_name, common_name) 

# analyze each population time series using GAM
gam = vector("list", length(df_gam_ls))
for(i in 1:length(gam)){
  tryCatch({
  gam[[i]] = compute_gam(df_gam_ls[[i]])},
  error = function(e) print(e))
}  
# name elements in list
names(gam) = unique(paste(df_gam$id_datasets, 
                          df_gam$org_event, 
                          df_gam$system,
                          df_gam$taxa, 
                          df_gam$scientific_name, 
                          df_gam$common_name, 
                          sep = "_"))
# save list
saveRDS(gam, "data/lpi_gam.RDS")

# calculate population growth rates (dt) with error propagation
pred_ls = vector("list", length(gam))
names(pred_ls) <- names(gam)
for(i in 1:length(pred_ls)){
  
  # don't run for the failed GAMs
  if(is.null(gam[[i]])){pred_ls[[i]] <- NA} else{
    
    # predict population sizes over full time period
    pred_ls[[i]] = mgcv::predict.gam(gam[[i]], newdata = year_pred, 
                             type = "response", se.fit = TRUE)
  }
}
# remove NA elements
pred_ls <- Filter(Negate(anyNA), pred_ls)

# calculate growth rates from GAM predictions
growthrates <- lapply(pred_ls, get_dt, year_pred = year_pred[,1]) %>% 
  bind_rows(.id = "popID") %>%
  # add information from LPD to predicted growth rates results
  separate(col = popID, sep = "_",
           into = c("id_datasets", "org_event", "system", 
                    "taxa", "genus", "species", "common_name")) %>%
  unite("scientific_name", genus:species, sep = "_")
# fill in common names for fake time series
growthrates$common_name[which(is.na(growthrates$common_name))] <- growthrates$scientific_name[which(is.na(growthrates$common_name))]

# fix bird errors, which balloon upwards in a non-realistic way
growthrates[which(growthrates$taxa == "oiseaux"), "cilo"] <- (growthrates[which(growthrates$taxa == "oiseaux"), "cilo"])/10
growthrates[which(growthrates$taxa == "oiseaux"), "cihi"] <- (growthrates[which(growthrates$taxa == "oiseaux"), "cihi"])/10

# join with chain method growth rate df
dt_chain$year_pred <- dt_chain$year_obs
growthrates <- bind_rows(growthrates, dt_chain)

# save
saveRDS(growthrates, "data/lpi_growthrates.rds")
