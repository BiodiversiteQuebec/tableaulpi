# Script to subset BioTIME and Living Planet Database datasets to Quebec

# load libraries
library(tidyr)
library(dplyr)
library(sf)

#### Living Planet Database ####

# This sections only needs to run once when first setting up:
# subset Living Planet Database to Quebec only ----

# load cropping function for Atlas (from Vincent Bellavance)
# source('data-raw/crop_qc.R')
# 
# # subset Living Planet Database (LPD) to Quebec
# lpd_qc <- lpdCropQc("LPR2020data_public.csv", dir = "data_raw/")
# 
# # save
# saveRDS(lpd_qc, "data/LPR2020data_public_qc.RDS")


# Getting LPD the same shape as Atlas ----

lpd_qc <- readRDS("data/LPR2020data_public_qc.RDS")

# convert to long format
lpd_qc_l <- lpd_qc %>%
  pivot_longer(cols = 30:98, values_to = "obs_value", names_to = "year_obs") %>%
  # remove NAs
  mutate_at(vars(obs_value), na_if, "NULL") %>% 
  drop_na(obs_value) %>%
  # convert classes
  mutate_at(vars(obs_value), as.numeric) %>%
  mutate_at(vars(year_obs), as.integer) %>%
  # add column to identify source of the observation
  mutate(id_datasets = "LPD") %>% 
  mutate(plot = ID) %>% # add column to identify the plot within the study (to match biotime)
  mutate(org_event = ID) #%>% # this is going to function as a population ID 
  #st_sf() # spatialize

# rename column names (some to match Atlas)
lpd <- rename(lpd_qc_l, 
              "scientific_name" = "Binomial",
              "common_name" = "Common_name",
              "family"= "Family",
              "system" = "System",
              "unit" = "Units",
              "methods" = "Method",
              "org_id_obs" = "ID",
              "lat" = "Latitude",
              "lon" = "Longitude",
              "geom" = "pts_sfc") # need to keep this for biotime

# add taxonomic group category for input selection
lpd$taxa <- NA
lpd$taxa[which(lpd$Class == "Actinopteri" | lpd$Class == "Elasmobranchii" | lpd$Class == "Myxini")] <- "poissons"
lpd$taxa[which(lpd$Class == "Mammalia")] <- "mammifères"
lpd$taxa[which(lpd$Class == "Reptilia")] <- "reptiles"
lpd$taxa[which(lpd$Class == "Aves")] <- "oiseaux"
lpd$taxa[which(lpd$Class == "Amphibia")] <- "amphibiens"

# transformation: add a small value to 0 to allow for modelling of time series

# find populations with observations of 0
with_zeros <- lpd$org_event[which(lpd$obs_value == 0)]

# following Collen 2008 method, get mean population measure 
with_zeros_means <- filter(lpd, org_event %in% with_zeros) %>%
  group_by(org_event) %>%
  summarise(mean_obs_value = mean(obs_value, na.rm = TRUE)) %>% ungroup()
# add these means to all years for these populations in order to correct for zeros
for(i in with_zeros_means$org_event){
  to_add <- with_zeros_means$mean_obs_value[which(with_zeros_means$org_event == i)]
  lpd$obs_value[which(lpd$org_event == i)] <- lpd$obs_value[which(lpd$org_event == i)] + to_add
}

# select necessary columns
lpd_sel <- select(lpd, c(id_datasets, org_event, plot, scientific_name, 
                         common_name, year_obs, obs_value, taxa, system, 
                         lon, lat))
lpd_sel$lat <- as.numeric(lpd_sel$lat)
lpd_sel$lon <- as.numeric(lpd_sel$lon)
lpd_sel$intellectual_rights <- "Living Planet Database"

# save object with sf geometry
saveRDS(lpd_sel, "data/lpd_qc.RDS")

#### SurVol Benthos ####

# Getting SurVol Benthos in the same shape as Atlas ----

# read SurvolBenthos validated dataset output from Atlas by Vincent/Ben
benthos <- readr::read_delim("data-raw/valid.csv", ";", 
                             escape_double = FALSE, trim_ws = TRUE)
# fill in columns needed for calculation/analysis of the LPI
benthos$taxa <- "invertébrés"
benthos$system <- "Freshwater"
benthos$org_event <- as.character(benthos$org_event)
benthos$id_datasets <- "SB"
benthos$common_name <- benthos$scientific_name

# transformation: add a small value to 0 to allow for modelling of time series

# find populations with observations of 0
with_zeros <- benthos$org_event[which(benthos$obs_value == 0)]

# following Collen 2008 method, get mean population measure 
with_zeros_means <- filter(benthos, org_event %in% with_zeros) %>%
  group_by(org_event) %>%
  summarise(mean_obs_value = mean(obs_value, na.rm = TRUE)) %>% ungroup()
# add these means to all years for these populations in order to correct for zeros
for(i in with_zeros_means$org_event){
  to_add <- with_zeros_means$mean_obs_value[which(with_zeros_means$org_event == i)]
  benthos$obs_value[which(benthos$org_event == i)] <- benthos$obs_value[which(benthos$org_event == i)] + to_add
}

# remove time series with >= 6 time steps (in a non-efficient way)
# split into list of individual population time series
benthos_ls = group_split(benthos, id_datasets, org_event, scientific_name, lon, lat) 
lengths <- unlist(lapply(benthos_ls, nrow))
benthos_ls <- benthos_ls[which(lengths >= 6)]
benthos <- bind_rows(benthos_ls)

#### FAKE DATA FOR TEST PURPOSES #### 
# ---- to remove after the prototype ## -----------

# create data frame to fill with fake data
fake <- matrix(NA, nrow = 150, ncol = ncol(lpd_sel), 
               dimnames = list(NULL, colnames(lpd_sel))) %>%
  as.data.frame()

# fill in the data frame with 5 time series of 10 years for each missing group
fake$taxa <- c(rep("amphibiens", 50), rep("oiseaux", 50), rep("reptiles", 50))
fake$system <- "Terrestrial"
fake$year_obs <- rep(2000:2009, 15)
fake[,c("id_datasets", "org_event", "plot")] <- "fake"
fake[,c("scientific_name", "common_name")] <- rep(letters[1:15], each = 10)
fake$obs_value <- runif(nrow(fake), min = 1, max = 1.5)
fake$intellectual_rights <- "Fake"

# assign random coordinates
temp <- rep(runif(15, min = 1, max = nrow(lpd_sel)), each = 10)
fake$lat <- as.numeric(lpd_sel$lat[temp]) + rnorm(length(temp), mean = 0, sd = 0.5)
fake$lon <- as.numeric(lpd_sel$lon[temp]) + rnorm(length(temp), mean = 0, sd = 0.5)


#### Put everything together in one data frame ####

lpd_qc_fake <- bind_rows(lpd_sel, benthos)
lpd_qc_fake <- bind_rows(lpd_qc_fake, fake)

# spatialize
lpd_qc_fake <- st_as_sf(lpd_qc_fake, coords = c("lon", "lat"))

# save object with sf geometry
saveRDS(lpd_qc_fake, "data/lpd_qc_fake.RDS")

# save internally in the tableauplpi package
usethis::use_data(lpd_qc_fake, overwrite = TRUE)