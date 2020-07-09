library(keras)
library(cloudml)
library(here)

cloudml::gcloud_init()

#-------------------------------------------------------------------------------
# Copy binary processed files to the bucket

cloudml::gs_rsync(
  source = here("data/processed/binary"),
  destination = "gs://covid-xray-deep/data/processed/binary",
  recursive = TRUE
)

#-------------------------------------------------------------------------------
# Test run

setwd(here("scripts/"))

cloudml_train(file = here("scripts/binary/train-cv.R"),
              master_type = "standard_p100", region = "europe-west1")

setwd(here())

job_collect()

sensitivities <- readRDS(
  file = here("runs/cloudml_2020_06_19_123843011/sensitivities.rds")
)