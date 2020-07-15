#' Generate weights based on the outcome variable
#' 
#' @details Please note that no validation of arguments is performed.
#' 
#' @param y An atomic vector or a factor that contains observed values of the
#' output variable.
#' 
#' @return A numeric vector of the same length as `y` containing weigths.
generate_weights <- function(y) {
  n <- length(y)
  n_classes <- length(unique(y))
  weigths <- n / (n_classes * table(sort(y)))
  names(weigths) <- unique(sort(y))
  return(as.list(weigths))
}
