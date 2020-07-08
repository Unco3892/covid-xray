library(here)
library(tidyverse)

set.seed(1)
test_ratio <- 0.2

#-------------------------------------------------------------------------------
# Create folders for binary and multiclass classifications

tasks <- c("binary", "multiclass")
subsets <- c("train", "test-balanced", "test")

binary_classes <- c("covid", "healthy")
multiclass_classes <- c("covid", "healthy", "bacterial", "viral")

binary_folders <- expand_grid(
  task = tasks[1],
  subset = subsets,
  class = binary_classes
)

multiclass_folders <- expand_grid(
  task = tasks[2],
  subset = subsets,
  class = multiclass_classes
)

folders <- bind_rows(binary_folders, multiclass_folders) %>%
  mutate(folder = here("data", "processed", task, subset, class))

folders %>% pull(folder) %>% lapply(dir.create, recursive = TRUE)

#-------------------------------------------------------------------------------
# Copy X-rays of COVID-infected patients

covid_images <- read_csv(
  here::here("data/raw/covid-chestxray-dataset/metadata.csv")
) %>%
  filter(finding == "COVID-19" & modality == "X-ray" & view == "PA") %>% 
  pull(filename) %>% 
  here("data/raw/covid-chestxray-dataset/images/", .)

covid_test_indices <- sample(
  x = seq_along(covid_images),
  size = test_ratio * length(covid_images)
)

# copy COVID-infected images to test folders
folders %>%
  filter(class == "covid" & subset %in% c("test", "test-balanced")) %>%
  pull(folder) %>% 
  lapply(file.copy, from = covid_images[covid_test_indices])

# copy COVID-infected images to train folders
folders %>%
  filter(class == "covid" & subset == "train") %>%
  pull(folder) %>% 
  lapply(file.copy, from = covid_images[-covid_test_indices])

#-------------------------------------------------------------------------------
# Copy X-rays of healthy patients

healthy_images <- c(
  list.files(
    path = here("data/raw/kermany/chest_xray/test/NORMAL/"),
    full.names = TRUE
  ),
  list.files(
    path = here("data/raw/kermany/chest_xray/train/NORMAL/"),
    full.names = TRUE
  )
)

healthy_test_indices <- sample(
  x = seq_along(healthy_images),
  size = test_ratio * length(healthy_images)
)

healthy_test_balanced_indices <- sample(
  x = healthy_test_indices,
  size = length(covid_test_indices)
)

# copy healthy images to test folders
folders %>%
  filter(class == "healthy" & subset == "test") %>%
  pull(folder) %>% 
  lapply(file.copy, from = healthy_images[healthy_test_indices])

# copy healthy images to balanced test folders
folders %>%
  filter(class == "healthy" & subset == "test-balanced") %>%
  pull(folder) %>% 
  lapply(file.copy, from = healthy_images[healthy_test_balanced_indices])

# copy healthy images to train folders
folders %>%
  filter(class == "healthy" & subset == "train") %>%
  pull(folder) %>% 
  lapply(file.copy, from = healthy_images[-healthy_test_indices])

#-------------------------------------------------------------------------------
# Copy X-rays for viral pneumonia

viral_images <- c(
  list.files(
    path = here("data/raw/kermany/chest_xray/test/PNEUMONIA/"),
    full.names = TRUE,
    pattern= "VIRUS"
  ),
  list.files(
    path = here("data/raw/kermany/chest_xray/train/PNEUMONIA/"),
    full.names = TRUE,
    pattern= "VIRUS"
  )
)

viral_test_indices <- sample(
  x = seq_along(viral_images),
  size = test_ratio * length(viral_images)
)

viral_test_balanced_indices <- sample(
  x = viral_test_indices,
  size = length(covid_test_indices)
)

# copy viral images (except COVID) to test folders
folders %>%
  filter(class == "viral" & subset == "test") %>%
  pull(folder) %>% 
  lapply(file.copy, from = viral_images[viral_test_indices])

# copy viral images (except COVID) to balanced test folders
folders %>%
  filter(class == "viral" & subset == "test-balanced") %>%
  pull(folder) %>% 
  lapply(file.copy, from = viral_images[viral_test_balanced_indices])

# copy viral images (except COVID) to train folders
folders %>%
  filter(class == "viral" & subset == "train") %>%
  pull(folder) %>% 
  lapply(file.copy, from = viral_images[-viral_test_indices])

#-------------------------------------------------------------------------------
# Copy X-rays for bacterial pneumonia

bacterial_images <- c(
  list.files(
    path = here("data/raw/kermany/chest_xray/test/PNEUMONIA/"),
    full.names = TRUE,
    pattern= "BACTERIA"
  ),
  list.files(
    path = here("data/raw/kermany/chest_xray/train/PNEUMONIA/"),
    full.names = TRUE,
    pattern= "BACTERIA"
  )
)

bacterial_test_indices <- sample(
  x = seq_along(bacterial_images),
  size = test_ratio * length(bacterial_images)
)

bacterial_test_balanced_indices <- sample(
  x = viral_test_indices,
  size = length(covid_test_indices)
)

# copy bacterial images to test folders
folders %>%
  filter(class == "bacterial" & subset == "test") %>%
  pull(folder) %>% 
  lapply(file.copy, from = bacterial_images[bacterial_test_indices])

# copy bacterial images to balanced test folders
folders %>%
  filter(class == "bacterial" & subset == "test-balanced") %>%
  pull(folder) %>% 
  lapply(file.copy, from = bacterial_images[bacterial_test_balanced_indices])

# copy bacterial images to train folders
folders %>%
  filter(class == "bacterial" & subset == "train") %>%
  pull(folder) %>% 
  lapply(file.copy, from = bacterial_images[-bacterial_test_indices])
