# Script to calculare the Living Planet Index per taxa group and for all 
# taxa groups together

# load libraries
require(tidyverse)
require(EnvStats)

# load functions
source("data-raw/00_lpi_functions.R")

# import population growth rates
growthrates <- readRDS("data/lpi_growthrates.RDS") 

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
             common_name = unique(growthrates_sp[[i]]$common_name)) %>%
      rename("dt" = "gm", "year_pred" = "year")
  } else{
    dt_gm_sp[[i]] <- growthrates_sp[[i]]
  }
}
names(dt_gm_sp) <- names(growthrates_sp)
# bind rows once again - wait they're not bindable, the columns are different
growthrates_sp <- bind_rows(dt_gm_sp, .id = "scientific_name")

## LPI per taxa group ----

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


## LPI for all groups ----

# get mean per year overall
dt_gm_tous <- dt_gm_group(growthrates, groupname = "tous")
# calculate overall LPI with confidence intervals
dt_gm_tous$lpi <- calclpi(dt_gm_tous$gm)
dt_gm_tous$lpi_cilo <- calclpi(dt_gm_tous$cilo)
dt_gm_tous$lpi_cihi <- calclpi(dt_gm_tous$cihi)

# bind all groups together
lpi_df <- bind_rows(dt_gm_taxa, .id = NULL) %>%
  rbind(dt_gm_tous) %>%
  select(c(group_id, year, gm, cilo, cihi, lpi, lpi_cilo, lpi_cihi)) %>%
  rename(taxa = group_id)
saveRDS(lpi_df, "data/lpi_index_taxa.RDS")


## LPI for each population ----

lpi_pops <- growthrates %>%
  group_by(org_event, scientific_name) %>% 
  # org_event is a unique ID per population in Living Planet Database
  # added scientific_name because the fake populations are all labelled "fake" in org_event
  mutate(lpi = calclpi(dt),
         lpi_cilo = calclpi(dt - 1.96*se),
         lpi_cihi = calclpi(dt + 1.96*se)) %>%
  mutate(trend = ifelse(round(dt, 4) < 1, "déclin", 
                        ifelse(round(dt, 4) > 1, "croissance", "stable"))) %>%
  ungroup()
saveRDS(lpi_pops, "data/lpi_index_populations.RDS")


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
                      select(temp, c(taxa, scientific_name, common_name)), 
                      by = "scientific_name")      
# copy table to create "tous" option
trend_tous <- trend_df
trend_tous$taxa <- "tous"
# combine with taxa-grouped trend table
trend_df <- rbind(trend_df, trend_tous)
saveRDS(trend_df, "data/lpi_trend_populations.RDS")
