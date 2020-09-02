library(keras)
library(cloudml)
library(caret)
library(here)

source(here::here("scripts/utility/load-data-from-directory.R"))
# source("scripts/utility/accuracy.R")
source(here::here("scripts/utility/generate-weights.R"))

# Define the hyperparameter for tuning
#-------------------------------------------------------------------------------

FLAGS <- flags(
  flag_numeric("wetights", 1)
)

#-------------------------------------------------------------------------------
# Read data and modify the outcome variable to use sigmoid activation function

data <- load_data_from_directory(
  path = here("data/processed/binary/train"),
  #path = gs_data_dir_local("gs://covid-xray-deep/data/processed/binary/train/"),
  target_size = c(224, 224)
)

data$y <- data$y - 1

#-------------------------------------------------------------------------------
# Create folds

set.seed(1968)

n_folds <- 5

folds <- createFolds(
  y = factor(data$y),
  k = n_folds,
  list = TRUE,
  returnTrain = TRUE
)

#-------------------------------------------------------------------------------
# Compute weights

classes_weights <- generate_weights(data$y)

#-------------------------------------------------------------------------------
# Define augmented and non-augmented (for validation set) generators

augmented_generator <- image_data_generator(
  zoom_range = 0.2,
  rescale = 1 / 255,
  horizontal_flip = TRUE
)

generator <- image_data_generator(rescale = 1 / 255)

#-------------------------------------------------------------------------------
# Define a container for sensitivities and accuracy metrics
# sensitivities <- numeric()
# accuracies <- numeric()

confusion_matrices <- list()

for (i in seq_along(folds)) {
  
  fold <- folds[[i]]
  
  # Define training and validation sets for the fold
  
  train_generator <- flow_images_from_data(
    x = data$x[fold, , ,],
    y = data$y[fold],
    generator = augmented_generator,
    batch_size = 32
  )
  
  valid_generator <- flow_images_from_data(
    x = data$x[-fold, , ,],
    y = data$y[-fold],
    generator = generator,
    batch_size = 32
  )
  
  # -----------
  # LENET5
  model <- keras_model_sequential() %>%
    layer_conv_2d(filters = 6, kernel_size = c(5, 5),
                  strides = 1, padding = "same", 
                  activation = "relu",
                  input_shape = c(224, 224, 3)) %>% 
    layer_average_pooling_2d(pool_size = c(2, 2), strides = 2) %>% 
    layer_conv_2d(filters = 16, kernel_size = c(5, 5),
                  strides = 1, activation = "relu") %>% 
    layer_average_pooling_2d(pool_size = c(2, 2), strides = 2) %>% 
    layer_conv_2d(filters = 120, kernel_size = c(5, 5),
                  strides = 1, activation = "relu") %>% 
    layer_flatten() %>%
    layer_dense(units = 84, activation = "relu") %>% 
    layer_dense(units = 1, activation = "sigmoid")
  
  # Compile with the flags
  model %>% compile(
    loss = loss_binary_crossentropy,
    optimizer = optimizer_rmsprop(0.0001),
    metric = metric_binary_accuracy
  )    
  
  # fit with the flags
  model %>% fit_generator(
    generator = train_generator, 
    steps_per_epoch = train_generator$n / train_generator$batch_size,
    epochs = 1,
    validation_data = valid_generator,
    validation_steps = valid_generator$n / valid_generator$batch_size,
    callbacks = callback_early_stopping(patience = 5,
                                        restore_best_weights = TRUE), 
    class_weight = classes_weights
  )   
  
  # -----------  
  valid_generator$batch_size <- valid_generator$n 
  valid_generator$shuffle <- FALSE
  
  predicted <- model %>% 
  predict_generator(generator = valid_generator, steps = 1)
  #predicted <- (apply(predicted, MARGIN = 1, which.max) - 1) %>% as.factor()
  predicted <- ifelse(predicted > 0.5, 1, 0) %>% as.numeric()
  observed <- valid_generator$y
  confusion_matrices[[i]] <-  confusionMatrix(factor(predicted, levels = c(0, 1)), factor(observed, levels = c(0, 1)))
  
  # sensitivities <- c(sensitivities,
  #                    sensitivity(factor(predicted), factor(observed)))
  # 
  # accuracies <- c(accuracies, 
  #                 accuracy(factor(predicted), factor(observed)))
  
}

# saveRDS(object = sensitivities, file = "sensitivities.rds")
# saveRDS(object = accuracies, file = "accuracies.rds")

saveRDS(object = confusion_matrices, file = "confusion_matrices.rds")
