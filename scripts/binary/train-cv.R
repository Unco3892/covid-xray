library(keras)
library(cloudml)
library(caret)
library(e1071)

source("utility/load-data-from-directory.R")
source("utility/generate-weights.R")

# Define the hyperparameter for tuning
#-------------------------------------------------------------------------------

FLAGS <- flags(
  flag_string("base", "vgg16"),
  flag_numeric("n_neurons", 100),
  flag_numeric("d_rate", 0.2),
  flag_numeric("batch_size", 16),
  flag_numeric("lr", 0.00001),
  flag_string("unfreeze_layer", "block5_conv1"),
  flag_boolean("use_weights", TRUE)
)

#-------------------------------------------------------------------------------
# Read data and modify the outcome variable to use sigmoid activation function

data <- load_data_from_directory(
  path = gs_data_dir_local("gs://covid-xray-deep/data/processed/binary/train/"),
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

confusion_matrices <- list()

for (i in seq_along(folds)) {

  fold <- folds[[i]]
    
  # Define training and validation sets for the fold

  train_generator <- flow_images_from_data(
    x = data$x[fold, , ,],
    y = data$y[fold],
    generator = augmented_generator,
    batch_size = FLAGS$batch_size
  )
  
  valid_generator <- flow_images_from_data(
    x = data$x[-fold, , ,],
    y = data$y[-fold],
    generator = generator,
    batch_size = FLAGS$batch_size
  )
  
  # Build the model
  
  if (FLAGS$base == "vgg16") {
    conv_base <- application_vgg16(
      include_top = FALSE,
      weights = "imagenet",
      input_shape = c(224, 224, 3)
    )
  } else if (FLAGS$base == "densenet201") {
    conv_base <- application_densenet201(
      include_top = FALSE,
      weights = "imagenet",
      input_shape = c(224, 224, 3)
    )
  }
  
  freeze_weights(conv_base)
  
  model <- keras_model_sequential() %>%
    conv_base %>%
    layer_flatten() %>%
    layer_dense(units = FLAGS$n_neurons, activation = "relu") %>%
    layer_dropout(rate = FLAGS$d_rate) %>%
    layer_dense(units = FLAGS$n_neurons, activation = "relu") %>%
    layer_dropout(rate = FLAGS$d_rate) %>%
    layer_dense(units = 1, activation = "sigmoid")
  
  model %>% compile(
    optimizer = optimizer_rmsprop(lr = FLAGS$lr),
    loss = loss_binary_crossentropy,
    metric = metric_binary_accuracy
  )
 
  # fit with the flags
  if(FLAGS$use_weights){
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
  }else{
    model %>% fit_generator(
      generator = train_generator, 
      steps_per_epoch = train_generator$n / train_generator$batch_size,
      epochs = 1,
      validation_data = valid_generator,
      validation_steps = valid_generator$n / valid_generator$batch_size,
      callbacks = callback_early_stopping(patience = 5,
                                          restore_best_weights = TRUE)
  } 
  
  unfreeze_weights(conv_base, from = FLAGS$unfreeze_layer)
  
  model %>% compile(
    optimizer = optimizer_rmsprop(lr = FLAGS$lr),
    loss = loss_binary_crossentropy,
    metric = metric_binary_accuracy
  )
  
  
  valid_generator$batch_size <- valid_generator$n 
  valid_generator$shuffle <- FALSE
  
  predicted <- model %>% 
    predict_generator(generator = valid_generator, steps = 1)
  predicted <- ifelse(predicted > 0.5, 1, 0) %>% as.numeric()
  observed <- valid_generator$y
  confusion_matrices[[i]] <- confusionMatrix(
    factor(predicted),
    factor(observed)
  )
  
}

saveRDS(object = confusion_matrices, file = "confusion_matrices.rds")
