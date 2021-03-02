
library(dplyr)

# read SurvolBenthos dataset output from Atlas by Vincent/Ben
benthos <- readr::read_delim("data-raw/valid.csv", ";", 
                      escape_double = FALSE, trim_ws = TRUE)
benthos <- sf::st_as_sf(benthos, coords = c("lon", "lat"))
benthos$taxa <- "invertébrés"
benthos$system <- "Freshwater"
benthos$org_event <- as.character(benthos$org_event)
benthos$id_datasets <- "SB"

df = benthos

# 0. add small value to 0 to allow for modelling of time series

# find populations with observations of 0
with_zeros <- df$org_event[which(df$obs_value == 0)]

# following Collen 2008 method, get mean population measure 
with_zeros_means <- filter(df, org_event %in% with_zeros) %>%
  group_by(org_event) %>%
  summarise(mean_obs_value = mean(obs_value, na.rm = TRUE)) %>% ungroup()
# add these means to all years for these populations in order to correct for zeros
for(i in with_zeros_means$org_event){
  to_add <- with_zeros_means$mean_obs_value[which(with_zeros_means$org_event == i)]
  df$obs_value[which(df$org_event == i)] <- df$obs_value[which(df$org_event == i)] + to_add
}

# 1. get time series length
duration_df = benthos %>% group_by(id_datasets, org_event, scientific_name) %>%
  summarise(duration = max(year_obs) - min(year_obs),
            steps = length(unique(year_obs))) 

# 2. identify populations to be analyzed with chain method (< 6 steps)

chain = duration_df$org_event[which(duration_df$steps < 6 & duration_df$steps >= 3)]
# extract datasets to analyze with chain method
df_chain = df[which(df$org_event %in% chain),]

# calculate growth rates (dt) using the chain method 
dt_chain =  df_chain %>% 
  group_by(id_datasets, org_event, scientific_name) %>%
  group_split() # break into a list
# for some reason, some time series are still too short at this point.
# re-filtering them here
lengths <- unlist(lapply(dt_chain, nrow))

# calculate growth rates
dt_chain_values <- lapply(dt_chain, FUN = function(x) { calc_dt_chain(x$obs_value)})
# put the growth rates in the subsetted df
dt_chain$dt <- unlist(dt_chain_values)
dt_chain$dt[which(dt_chain$dt == -Inf)] <- 0

# 3. select populations to analyze with GAM method

gam = duration_df$org_event[which(duration_df$steps > 6)]
# extract datasets to analyze with GAM method
df_gam = df[which(df$org_event %in% gam),]


# GAM method -------------------------------------------------------------------

# split into list of individual population time series
df_gam$obs_value_log10 <- log10(df_gam$obs_value)
df_gam_ls = group_split(df_gam, id_datasets, org_event, scientific_name) 
lengths <- unlist(lapply(df_gam_ls, nrow))
df_gam_ls <- df_gam_ls[which(lengths >= 6)]
df_gam <- bind_rows(df_gam_ls)
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
                          #df_gam$common_name, 
                          sep = "_"))
# save list
saveRDS(gam, "data/lpi_gam.RDS")

# time period for which the indicator is being calculated
year_pred <- data.frame("year_obs" = 1990:2018)

# calculate population growth rates (dt) with error propagation
pred_ls = vector("list", length(gam))
names(pred_ls) <- names(gam)
for(i in 1:length(pred_ls)){
  
  # don't run for the failed GAMs
  if(is.null(gam[[i]])){dt_gam[,i] <- NA} else{
    
    # predict population sizes over full time period
    pred_ls[[i]] = mgcv::predict.gam(gam[[i]], newdata = year_pred, 
                                     type = "response", se.fit = TRUE)
  }
}

# function to calculate dt from GAM predictions
# gam.pred_ls: list of predictions from GAMs (one per population)
# year_pred: vector of years to predict 
get_dt <- function(gam.pred_ls, year_pred){
  
  # extract predicted population size values
  # un-log10
  N = 10^gam.pred_ls$fit  # un-log
  
  # initialize df to store dts
  dt_df = data.frame(year_pred = year_pred, dt = NA)
  for(i in 2:length(N)){
    # calculate dt
    dt = log10(N[i]/N[i-1])
    dt_df[i, "dt"] = dt # save in the table
  }
  return("dt" = dt_df)
}


# calculate growth rates from GAM predictions
growthrates <- lapply(pred_ls, get_dt, year_pred = year_pred[,1]) %>% 
  bind_rows(.id = "popID") %>%
  # add information from LPD to predicted growth rates results
  tidyr::separate(col = popID, sep = "_",
           into = c("id_datasets", "org_event", "system", 
                    "taxa", "genus", "species")) %>%
  tidyr::unite("scientific_name", genus:species, sep = "_")
# fill in common names for fake time series
#growthrates$common_name[which(is.na(growthrates$common_name))] <- growthrates$scientific_name[which(is.na(growthrates$common_name))]

# fix bird errors, which balloon upwards in a non-realistic way
#growthrates[which(growthrates$taxa == "oiseaux"), "se"] <- (growthrates[which(growthrates$taxa == "oiseaux"), "se"])/10

# save
#saveRDS(growthrates, "data/lpi_growthrates.rds")

## get growth rates per species ----

# split into list by scientific name
growthrates_sp <- split(growthrates, growthrates$scientific_name)

# get mean per year per species
dt_gm_sp <- vector("list", length(growthrates_sp))
for(i in 1:length(dt_gm_sp)){
  if(length(unique(growthrates_sp[[i]]$org_event)) > 1){
    temp <- dt_gm_group(growthrates_sp[[i]], names(growthrates_sp)[i])
    dt_gm_sp[[i]] <- temp %>% 
      mutate(system = unique(growthrates_sp[[i]]$system),
             taxa = unique(growthrates_sp[[i]]$taxa),
             scientific_name = unique(growthrates_sp[[i]]$scientific_name),
             #common_name = unique(growthrates_sp[[i]]$common_name)
             ) %>%
      rename("dt" = "gm", "year_pred" = "year")
  } else{
    dt_gm_sp[[i]] <- growthrates_sp[[i]]
  }
}
names(dt_gm_sp) <- names(growthrates_sp)
# bind rows once again - wait they're not bindable, the columns are different
growthrates_sp <- bind_rows(dt_gm_sp, .id = "scientific_name")

# split into taxa groups
growthrates_ls <- split(growthrates_sp, growthrates_sp$taxa)

# get mean per year per taxa
dt_gm_taxa <- vector("list", length(growthrates_ls))
for(i in 1:length(dt_gm_taxa)){
  dt_gm_taxa[[i]] <- dt_gm_group(growthrates_ls[[i]], 
                                 names(growthrates_ls)[i])
}

# calculate LPI per taxa with confidence intervals
for(i in 1:length(dt_gm_taxa)){
  dt_gm_taxa[[i]]$lpi <- calclpi(dt_gm_taxa[[i]]$gm)
  dt_gm_taxa[[i]]$lpi_cilo <- calclpi(dt_gm_taxa[[i]]$cilo)
  dt_gm_taxa[[i]]$lpi_cihi <- calclpi(dt_gm_taxa[[i]]$cihi)
}
# bind all groups together
lpi_df <- bind_rows(dt_gm_taxa, .id = NULL) %>%
  select(c(group_id, year, gm, cilo, cihi, lpi, lpi_cilo, lpi_cihi)) %>%
  rename(taxa = group_id)

## LPI for each population ----

lpi_pops <- growthrates %>%
  group_by(org_event, scientific_name) %>% 
  # org_event is a unique ID per population in Living Planet Database
  # added scientific_name because the fake populations are all labelled "fake" in org_event
  mutate(lpi = calclpi(dt)#,
#         lpi_cilo = calclpi(dt - 1.96*se),
#         lpi_cihi = calclpi(dt + 1.96*se)
) %>%
  mutate(trend = ifelse(round(dt, 4) < 1, "déclin", 
                        ifelse(round(dt, 4) > 1, "croissance", "stable"))) %>%
  ungroup()
#saveRDS(lpi_pops, "data/lpi_index_populations.RDS")

## mean growth rate for each species ----

# split into list
pops_ls <- split(growthrates_sp, growthrates_sp$scientific_name)
pop_df <- data.frame("scientific_name" = names(pops_ls), 
                     "dt" = NA, cilo = NA, cihi = NA)
for(i in 1:length(pops_ls)){ # broken
  pop_df[i, 2:4] <- dt_boot(10^pops_ls[[i]]$dt) 
}

# add column to describe growth rate trend category 
trend_df <- pop_df %>%
  mutate(trend = ifelse(round(dt, 4) < 1, "déclin", 
                        ifelse(round(dt, 4) > 1, "croissance", "stable")))
temp <- growthrates[!duplicated(growthrates$scientific_name),]
trend_df <- inner_join(trend_df, 
                       select(temp, c(taxa, scientific_name
                                      #, common_name
                                      )), 
                       by = "scientific_name")      

#saveRDS(trend_df, "data/lpi_trend_populations.RDS")
