library(tidyverse)
library(sf)
library(lubridate)
library(parallel)
library(dplyr)


## read in kyle's funciton from GitHub
#devtools::source_url("https://raw.githubusercontent.com/kyledougherty/CougR/main/a_LoCoH_HR_Function.R")

## or, read in locally:
source("a_LoCoH_HR2.R") ## I manipulated this FYI  

##read in data, obviously change to your own path
read.csv("data/ecotone_data_hourly") -> ecotone_data
## format data for LoCoH function
test <- ecotone_data %>% 
  #filter(ID %in% c('82471', '82411')) %>% ## filter for two elk to test code quickly
  drop_na() %>% 
  rename(y  = `Latitude`, 
         x  = `Longitude`) %>% 
  ## something strange is going on with the formatting for the time column...
  ## convert to character before converting to dttm type
  mutate(dt = mdy_hm(as.character(dt), tz = 'UTC')) %>% 
  st_as_sf(coords = c("x", "y"), 
           crs = 4326, remove = FALSE) %>% ## remove = FALSE keeps original lat/long columns - usually a good idea to keep
  st_transform(26911) %>% ## you may need to change this for some elk - do any cross into zone 14?
  group_by(ID) %>%
  group_split(1)


## run function
start <- Sys.time()
Home_Range_Estimate <- lapply(test, 
                              a_LoCoH_HR2, 
                              id = "ID",
                              date = "dt",
                              iso_levels = c(0.95)
)
Sys.time() - start
## Time difference of 35.16428 secs

#plot(Home_Range_Estimate$geometry)

#get rid of rows with insufficient data
#Home_Range_Estimate = Home_Range_Estimate[-c(15)]

Home_Range_Estimate %>% bind_rows() -> HR_df_fallcaps


####Plotting home ranges#####
#convert to sf object
HR_sf_fallcaps <- st_as_sf(HR_df_fallcaps)

ggplot()+
  geom_sf(data = HR_sf_calv)
