library(tidyverse)
library(here)

#-------------------------------------------------------------------------------
# `covid-chestxray-dataset` dataset EDA

data_covid19 <- read_csv(
  here::here("data/raw/covid-chestxray-dataset/metadata.csv")
)

# Number of patients with all diseases (387 persons)
data_covid19 %>% count(patientid) %>% nrow()

# Number of patients infected with COVID (288 persons)
# Some of these images are CT scans and not X-rays and also includes multiple
# angles of the X-ray scan
data_covid19 %>% filter(finding == "COVID-19") %>% count(patientid) %>% nrow()

# The focus is on images of X-rays that could be a replacement to data
# augmentation, not on patients

# Number of X-rays of COVID infected patients with different angels (441
# instances) 
data_covid19 %>% filter(finding == "COVID-19" & modality == "X-ray") %>% nrow()

# Number of X-rays of COVID infected patients with PA (posteroanterior) angle
# (201 instances)
data_covid19 %>%
  filter(finding == "COVID-19" & modality == "X-ray" & view == "PA") %>% 
  count()
