accuracy <- function(predicted, observed) {
  confusion <- table(predicted, observed)
  true <- confusion[ 
    seq(from = 1, to = length(confusion), by = sqrt(length(confusion)) + 1)
  ]
  sum(true) / sum(confusion)
}
