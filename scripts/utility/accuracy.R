#' Compute accuracy given predicted and observed values
#' 
#' @details Please note that no validation of arguments is performed.
#' 
#' @param predicted An atomic vector or a factor of the same length as
#' `observed` that contains predicted values.  
#' @param observed An atomic vector or a factor of the same length as
#' `predicted` that contain observed values.  
#' 
#' @return A numeric vector of length one that contains accuracy.
accuracy <- function(predicted, observed) {
  confusion <- table(predicted, observed)
  true <- confusion[ 
    seq(from = 1, to = length(confusion), by = sqrt(length(confusion)) + 1)
  ]
  sum(true) / sum(confusion)
}
