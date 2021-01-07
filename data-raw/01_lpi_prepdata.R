# Script to subset BioTIME and Living Planet Database datasets to Quebec

# load libraries
library(tidyverse)
library(sf)

# subset Living Planet Database to Quebec only ----

# load cropping function for Atlas (from Vincent Bellavance)
source('data-raw/crop_qc.R')

# subset Living Planet Database (LPD) to Quebec
lpd_qc <- lpdCropQc("LPR2020data_public.csv", dir = "data_raw/")

# save
saveRDS(lpd_qc, "data/LPR2020data_public_qc.RDS")


# dataset manipulation ----

# convert to long format
lpd_qc_l <- lpd_qc %>%
  pivot_longer(cols = 30:98, values_to = "obs_value", names_to = "year_obs") %>%
  # remove NAs
  mutate_at(vars(obs_value), na_if, "NULL") %>% drop_na(obs_value) %>%
  # convert classes
  mutate_at(vars(obs_value), as.numeric) %>%
  mutate_at(vars(year_obs), as.integer) %>%
  # add column to identify source of the observation
  mutate(id_datasets = "LPD") %>% 
  mutate(plot = ID) %>% # add column to identify the plot within the study (to match biotime)
  mutate(org_event = ID) %>% # this is going to function as a population ID 
  st_sf() # spatialize

# rename column names (some to match Atlas)
lpd <- rename(lpd_qc_l, 
              "scientific_name" = "Binomial",
              "common_name" = "Common_name",
              "family"= "Family",
              "system" = "System",
              "unit" = "Units",
              "methods" = "Method",
              "org_id_obs" = "ID",
              "geom" = "pts_sfc") # need to keep this for biotime

# add taxonomic group category for input selection
lpd$taxa <- NA
lpd$taxa[which(lpd$Class == "Actinopteri" | lpd$Class == "Elasmobranchii" | lpd$Class == "Myxini")] <- "poissons"
lpd$taxa[which(lpd$Class == "Mammalia")] <- "mammifères"
lpd$taxa[which(lpd$Class == "Reptilia")] <- "reptiles"
lpd$taxa[which(lpd$Class == "Aves")] <- "oiseaux"
lpd$taxa[which(lpd$Class == "Amphibia")] <- "amphibiens"

# select necessary columns
lpd_sel <- select(lpd, c(id_datasets, org_event, plot, scientific_name, 
                         common_name, year_obs, obs_value, taxa, system))
# save object with sf geometry
saveRDS(lpd_sel, "data/lpd_qc.RDS")



## FAKE DATA FOR TEST PURPOSES ---- to remove after the prototype ## -----------

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
fake$obs_value <- runif(nrow(fake), min = 20, max = 40)
# assign random coordinates from original dataset
fake$geom <- lpd_qc$pts_sfc[runif(nrow(fake), min = 1, max = nrow(lpd_qc))]
fake <- st_as_sf(fake, sf_column_name = "geom", crs = st_crs(lpd_sel))
# add noise to coordinates so they don't overlap
fake <- st_jitter(fake, amount = 1)
# bind to lpd dataframe
lpd_sel_fake <- bind_rows(lpd_sel, fake)

# save object with sf geometry
saveRDS(lpd_sel_fake, "data/lpd_qc_fake.RDS")
