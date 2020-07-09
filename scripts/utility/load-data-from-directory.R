library(here)
library(abind)
library(magrittr)

load_image <- function(path, target_size) {
    image_load(path = path, target_size = target_size) %>% image_to_array()
}

load_directory <- function(path, target_size) {
    files <- list.files(path = path, full.names = TRUE)
    array_list <- lapply(files, load_image, target_size = target_size)
    abind(array_list, along = 0)
}

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
