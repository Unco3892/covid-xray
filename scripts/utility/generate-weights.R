generate_weights <- function(y) {
  n <- length(y)
  n_classes <- length(unique(y))
  weigths <- n / (n_classes * table(sort(y)))
  names(weigths) <- unique(sort(y))
  return(as.list(weigths))
}
