library(tidyverse)
library(here)

# =================
# EDA (only COVID+)
# =================

# Import the data
data_covid19 <- read.csv(here::here("data/raw/covid-chestxray-dataset/metadata.csv"))

# Number of total patients with all diseases (387 persons)
data_covid19 %>% count(patientid) %>% nrow()

# Number of total patients with COVID+ (288 persons), some of these are CT scans and not X-rays
data_covid19 %>% filter(finding == "COVID-19") %>% count(patientid) %>% nrow()
# We do not care about the patients but rather images which could be a replacement to data augmentation.

# Number of total patients with COVID+ (288 persons), some of these are CT scans and not X-rays and also includes multiples angles of the x-ray scan
data_covid19 %>% filter(finding == "COVID-19") %>% count(patientid) %>% nrow()

# Number of x-rays we have of COVID+ (441 instances) in all the views
data_covid19 %>% filter(finding == "COVID-19" & modality == "X-ray") %>% nrow()

# WHAT WE WILL USE: Number of x-rays we have of COVID+ PA angle (201 instances)
only_covid <- data_covid19 %>%
  filter(finding == "COVID-19" & modality == "X-ray" & view == "PA")

# We can see that there are 201 instances
nrow(only_covid)