library(here)
library(abind)
library(magrittr)

#' Read the image into R array
#' 
#' @details A file should have PNG, JPG, BMP, PPM, or TIF extension.
#' 
#' @param path A character vector of length one, a path to the image file.
#' @param target_size An integer vector of length two, `(height, width)`.
#' 
#' @return An array of three dimensions: `(height, width, channel)`.
load_image <- function(path, target_size) {
    image_load(path = path, target_size = target_size) %>% image_to_array()
}

#' Read images from the directory.
#' 
#' @details All files in `path` directory should be images with PNG, JPG, BMP,
#' PPM, or TIF extensions.
#' 
#' @param path A character vector of length one, a path to the folder with image
#' files. 
#' @param target_size An integer vector of length two, `(height, width)`.
#' 
#' @return An array of four dimensions: `(sample, height, width, channel)`.
load_directory <- function(path, target_size) {
    files <- list.files(path = path, full.names = TRUE)
    array_list <- lapply(files, load_image, target_size = target_size)
    abind(array_list, along = 0)
}

#' Generate input and output from the folder structure and images.
#' 
#' @details All files in `path` directory should be images with PNG, JPG, BMP,
#' PPM, or TIF extensions.
#' 
#' @param path A character vector of length one, a path to the folder with image
#' files. It should contain one sub-directory per class.
#' @param target_size An integer vector of length two, `(height, width)`.
#' 
#' @return A list of two elements: 
#' \itemize{
#'   \item \code{x}: an array of four dimensions
#'   `(sample, height, width, channel)`, input for the model
#'   \item \code{y}: an integer vector that represents classes
#' }
load_data_from_directory <- function(path, target_size) {
    
    directoreis <- list.dirs(
        path = path,
        recursive = FALSE,
        full.names = TRUE
    )
    
    array_list <- lapply(directoreis, load_directory, target_size = target_size)
    
    n_observations <- sapply(array_list, function(x) dim(x)[1])
    
    list(
        x = abind(array_list, along = 1),
        y = rep(1:length(directoreis), n_observations)
    )
    
}
