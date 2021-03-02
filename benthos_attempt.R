
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
duration_df = benthos %>% group_by(org_event, scientific_name) %>%
  summarise(duration = max(year_obs) - min(year_obs),
            steps = length(unique(year_obs))) 

# remove empty time series
duration_df <- filter(duration_df, duration > 0)

# 2. identify populations to be analyzed with chain method (< 6 steps)

chain = duration_df$org_event[which(duration_df$steps < 6 & duration_df$steps >= 2)]
# extract datasets to analyze with chain method
df_chain = df[which(df$org_event %in% chain),]

# 3. select populations to analyze with GAM method

gam = duration_df$org_event[which(duration_df$steps > 6 & duration_df$duration > 6)]
# extract datasets to analyze with GAM method
df_gam = df[which(df$org_event %in% gam),]

# calculate growth rates (dt) using the chain method 
dt_chain =  df_chain %>%
  group_by(id_datasets, org_event, scientific_name) %>% group_split()
dt_chain_values <- lapply(dt_chain, FUN = function(x) { calc_dt_chain(x$obs_value)})
  group_map(calc_dt_chain(obs_value))
dt_chain$dt[which(dt_chain$dt == -Inf)] <- 0
