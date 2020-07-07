# =================
# PROCESSING IMAGES
# =================

# Run "eda.R" first in your enviroment.

# --------------------
# Creating the folders
# --------------------
# Directories for both binary and multiclass classifications
mainfolder_names <- c("binary/", "multiclass/")
subfolder1_names <- c("train/", "test-small/", "test-large/")
subfolder2_names <- c("COVID+", "COVID-", "Pneumonia_bacterial", "Pneumonia_viral")

for (i in 1:length(mainfolder_names)) {
  paste <- paste0("/data/processed/", mainfolder_names[i])
  for (j in 1:length(subfolder1_names)) {
    paste2 <- here::here(paste0(paste, subfolder1_names[j]))
    folder <- dir.create(paste2, recursive = TRUE)
    for (h in 1:length(subfolder2_names)) {
      if (str_detect(paste2, "binary")) {
        folder2 <- dir.create(paste0(paste2, subfolder2_names[1]), recursive = TRUE) #COVID+
        folder3 <- dir.create(paste0(paste2, subfolder2_names[2]), recursive = TRUE) #COVID-
      } else{
        folder_4 <-dir.create(paste0(paste2, subfolder2_names[h]), recursive = TRUE) #All four categories
      }
    }
  }
}

# --------------------
# COVID+ 
# --------------------
# Proportions of the testing and train, here we use 80% for training and the rest for test
split_prop <- round(0.8 * nrow(only_covid))
filestocopy_pos_train <- as.vector(only_covid$filename)[1: split_prop]
filestocopy_pos_test <- as.vector(only_covid$filename)[(split_prop+1):nrow(only_covid)]


# !!!The code below could be shortened!!!
  # We write a loop to move the COVID+ photos to our chest-x-ray ones
for (i in 1: length(mainfolder_names)){
  # Set both the directory to take the images as well as the target directory
  org_dir_pos <- here::here("data/raw/covid-chestxray-dataset/images")
  tar_dir_pos_train <- here::here(paste0("data/processed/", mainfolder_names[i], "train/COVID+"))
  tar_dir_pos_small_test <- here::here(paste0("data/processed/", mainfolder_names[i], "test-small/COVID+"))
  tar_dir_pos_large_test <- here::here(paste0("data/processed/", mainfolder_names[i], "test-large/COVID+"))
  # We copy the files for the train set (COVID+)
  lapply(filestocopy_pos_train, function(x)
    file.copy(
      paste (org_dir_pos, x , sep = "/"),
      paste (tar_dir_pos_train, x, sep = "/"),
      recursive = FALSE,
      copy.mode = TRUE,
      overwrite = TRUE
    ))
  # We copy the files for the small test set(COVID+)
  lapply(filestocopy_pos_test, function(x)
    file.copy(
      paste (org_dir_pos, x , sep = "/"),
      paste (tar_dir_pos_small_test, x, sep = "/"),
      recursive = FALSE,
      copy.mode = TRUE,
      overwrite = TRUE
    ))
  # We copy the files for the test set (COVID+)
  lapply(filestocopy_pos_test, function(x)
    file.copy(
      paste (org_dir_pos, x , sep = "/"),
      paste (tar_dir_pos_large_test, x, sep = "/"),
      recursive = FALSE,
      copy.mode = TRUE,
      overwrite = TRUE
    ))
}

# --------------------
# COVID-
# --------------------
# Here we will also create balanced dataset, however we will use all the images from the test and train in the processes.

# Set the original directory for the negative covid cases (labled NORMAL)
# Note: Sampling Images from the kermany data for normal to have a balanced dataset
org_dir_neg_train <- here::here("data/raw/kermany/images/train/NORMAL")
org_dir_neg_test <- here::here("data/raw/kermany/images/test/NORMAL")

# Here we have a particular situation as we have two training directories
# Now list the training files in the original training directory
jpeg2_train <- list.files(org_dir_neg_train, pattern = ".jpeg")
jpeg2_test <- list.files(org_dir_neg_test, pattern = ".jpeg") # Now list the test files in the original training directory

# We randomly take the same number photos as COVID+ and then divide them into train and test
set.seed(5)
all_negatives <- as.vector(sample(jpeg2_train, nrow(only_covid)))
filestocopy_neg_train <- all_negatives[1: split_prop]
filestocopy_neg_test <- all_negatives[(split_prop+1):nrow(only_covid)]

# We write a loop to move the COVID+ photos to both binary and multiclass folders
for (i in 1: length(mainfolder_names)){
  # Set the target directory for negative COVID cases
  tar_dir_neg_train <- here::here(paste0("data/processed/", mainfolder_names[i], "train/COVID-"))
  tar_dir_neg_small_test <- here::here(paste0("data/processed/", mainfolder_names[i], "test-small/COVID-"))
  tar_dir_neg_large_test <- here::here(paste0("data/processed/", mainfolder_names[i], "test-large/COVID-"))
  # We copy the files for the train set (COVID+)
  lapply(filestocopy_pos_train, function(x)
    file.copy(
      paste (org_dir_neg_train, x , sep = "/"),
      paste (tar_dir_neg_train, x, sep = "/"),
      recursive = FALSE,
      copy.mode = TRUE,
      overwrite = TRUE
    ))
  # We copy the files for the small test set(COVID+)
  lapply(filestocopy_neg_test, function(x)
    file.copy(
      paste (org_dir_neg_train, x , sep = "/"),
      paste (tar_dir_neg_small_test, x, sep = "/"),
      recursive = FALSE,
      copy.mode = TRUE,
      overwrite = TRUE
    ))
  lapply(jpeg2_train, function(x)
    file.copy(
      paste (org_dir_neg_train, x , sep = "/"),
      paste (tar_dir_neg_large_test, x, sep = "/"),
      recursive = FALSE,
      copy.mode = TRUE,
      overwrite = TRUE
    ))
  # We copy the files for the test set (COVID+)
  lapply(jpeg2_test, function(x)
    file.copy(
      paste (org_dir_neg_test, x , sep = "/"),
      paste (tar_dir_neg_large_test, x, sep = "/"),
      recursive = FALSE,
      copy.mode = TRUE,
      overwrite = TRUE
    ))
}



# !=======!
# The same model as above can be applied below.

# --------------------
# Pneumonia_bacterial
# --------------------
# Sampling Images from the kermany data for VIRAL pneumonia to have a balanced dataset

# Set both the directory to take the images as well as the target directory for negative COVID cases
org_dir_viral <- here::here("data/kermany_OTHERS/chest_xray/train/PNEUMONIA")
tar_dir_vir_train <- here::here("data/final_data/train/Pneumonia_viral")
tar_dir_vir_test <- here::here("data/final_data/test/Pneumonia_viral")

# Now list the files
jpeg3 <- list.files(org_dir_viral, pattern = "VIRUS")

# We randomly take the same number photos as the COVID+
set.seed(5)
all_virus <- as.vector(sample(jpeg3, nrow(only_covid)))
filestocopy_vir_train <- all_virus[1:112]
filestocopy_vir_test <- all_virus[113:140]

# We copy the files for the train (VIRAL +)
lapply(filestocopy_vir_train, function(x)
  file.copy(
    paste (org_dir_viral, x , sep = "/"),
    paste (tar_dir_vir_train, x, sep = "/"),
    recursive = FALSE,
    copy.mode = TRUE,
    overwrite = TRUE
  ))

# We copy the files for the test (VIRAL +)
lapply(filestocopy_vir_test, function(x)
  file.copy(
    paste (org_dir_viral, x , sep = "/"),
    paste (tar_dir_vir_test, x, sep = "/"),
    recursive = FALSE,
    copy.mode = TRUE,
    overwrite = TRUE
  ))

# --------------------
# Pneumonia_viral
# --------------------
# Sampling Images from the kermany data for BACTERIAL pneumonia to have a balanced dataset

# Set both the directory to take the images as well as the target directory for negative COVID cases
org_dir_bac <- here::here("data/kermany_OTHERS/chest_xray/train/PNEUMONIA")
tar_dir_bac_train <- here::here("data/final_data/train/Pneumonia_bacterial")
tar_dir_bac_test <- here::here("data/final_data/test/Pneumonia_bacterial")

# Now list the files
jpeg4 <- list.files(org_dir_bac, pattern = "BACTERIA")

# We randomly take the same number photos as the COVID+
set.seed(5)
all_bacteria <- as.vector(sample(jpeg4, nrow(only_covid)))
filestocopy_bac_train <- all_bacteria[1:112]
filestocopy_bac_test <- all_bacteria[113:140]

# Finally, we once again copy the files for the train (BACTERIAL +)
lapply(filestocopy_bac_train, function(x)
  file.copy(
    paste (org_dir_bac, x , sep = "/"),
    paste (tar_dir_bac_train, x, sep = "/"),
    recursive = FALSE,
    copy.mode = TRUE,
    overwrite = TRUE
  ))

# We do the same for the train set of (BACTERIAL +)
lapply(filestocopy_bac_test, function(x)
  file.copy(
    paste (org_dir_bac, x , sep = "/"),
    paste (tar_dir_bac_test, x, sep = "/"),
    recursive = FALSE,
    copy.mode = TRUE,
    overwrite = TRUE
  ))