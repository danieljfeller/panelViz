library(dplyr)





# helper functions
shuffleDF <- function(X){
  rows <- sample(nrow(X))
  return(X[rows, ])}
proportion <- function(X){
  return(sum(X == TRUE)/length(X))
}
increasePrevalence <- function(X){
    new_vector = c()
    counter = 0
    for (x in X){
      if (x == FALSE & counter < 100) {
        new_vector <- c(new_vector, TRUE)
        counter = counter + 1
      }
      else{
        new_vector <- c(new_vector, x)
      }
    }
    return(new_vector)
}
decreasePrevalence <- function(X){
  new_vector = c()
  counter = 0
  for (x in X){
    if (x == TRUE & counter < 100) {
      new_vector <- c(new_vector, FALSE)
      counter = counter + 1
    }
    else{
      new_vector <- c(new_vector, x)
    }
  }
  return(new_vector)
}

# decrease prevalence by 20% if X < 20%, otherwise increase by 20%
divergeBinary <- function(X){
  if (proportion(X) < 0.2) {
    X = increasePrevalence(X)
  } else {
    X = X
  }
  return(X)
}



dicks = divergeBinary(panelViz_dataset$new_dx)

##########################
# load & shuffle dataset #
##########################

panelViz_dataset <- read.csv('panelViz_dataset.csv')
panelViz_dataset <- shuffleDF(panelViz_dataset)

baseline_dataset <- read.csv('baseline_dataset.csv')
baseline_dataset <- shuffleDF(baseline_dataset)


