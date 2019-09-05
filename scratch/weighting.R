animals <- c('dog', 'cat', 'cock')

magiq <- function(list){
  weights <- c()
  for (i in 1:length(list)){
    weights[i] <- (1/i)/length(list)
  }
  return(weights)
}

magiq(animals)
