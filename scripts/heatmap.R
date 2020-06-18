library(keras)
library(here)
library(magrittr)
library(tensorflow)
library(magick) 
library(tidyverse)

# Visualizing the images
# We take on COVID+ and one COVID- and the same for multiclass classification
# Class activation map
# We will use gradcam from here and here
# https://jjallaire.github.io/deep-learning-with-r-notebooks/notebooks/5.4-visualizing-what-convnets-learn.nb.html
# ----------------
# Multiclass vgg16
vgg16_mc <- load_model_hdf5(here::here("best_models/vgg16_mc/best_vgg16_mc.h5"))

tf$compat$v1$disable_eager_execution()

color_generator <- grDevices::colorRampPalette(c("#000000", "#ffffff"))
colors <- color_generator(255)

daisy <- here::here(
  "data/final_data/binary/test/COVID+/paving.jpg")%>%
  image_load(target_size = c(224, 224)) %>% 
  image_to_array() %>%
  array_reshape(c(1, 224, 224, 3)) %>% 
  divide_by(255)

# daisy[1, , , ] %>% as.raster() %>% plot()
# dev.off()

# Make the binary prediction here

# Make the multiclass predictionzZ  
preds <- vgg16_mc %>% predict(daisy)

# The prediction which is of class zero is COVID+
which.max(preds[1, ])- 1

# TRICK: This part gives the four classes
vgg16_output <- vgg16_mc$output[,1]

# This may not be correct? How do you pull a layer from a model?
last_conv_layer <- vgg16_mc$layer %>% get_layer("vgg16") %>% get_layer("block5_conv3")

# vgg16_mc %>% get_layer("block5_conv1")$input

# To extract the last convolutional layer
last_conv_layer <- vgg16_mc %>% get_layer("dense_4")

# get_layer("vgg16") %>% 
last_conv_layer
last_conv_layer$output


# ---------------
# You can see that the PROBLEM occurs here: Applying the grad algo but the outcome is null
grads <- k_gradients(vgg16_output, last_conv_layer$output)[[1]]

# k-means and pooled grads
pooled_grads <- k_mean(grads, axis = c(1, 2, 3))

iterate <- k_function(list(vgg16_binary$input),
                      list(pooled_grads, last_conv_layer$output[1,,,]))

c(pooled_grads_value, conv_layer_output_value) %<-% iterate(list(daisy))

for (i in 1:64) {
  conv_layer_output_value[,,i] <- 
    conv_layer_output_value[,,i] * pooled_grads_value[[i]] 
}

heatmap <- apply(conv_layer_output_value, c(1,2), mean)
heatmap <- pmax(heatmap, 0) 
heatmap <- heatmap / max(heatmap)
