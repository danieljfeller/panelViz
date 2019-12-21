# range standardization
standard_range <- function(x){
  (x-min(x))/(max(x)-min(x))
  }

# converts Yes/No to 1/0
yes2one <- function(x){
  return(ifelse(x =='Yes', 1, 0))
}

# computes MAGIQ weights for an ordered list of column names
magiqWeights <- function(list){
  weights <- c()
  for (i in 1:length(list)){
    weights[i] <- (1/i)/length(list)
  }
  return(weights)
}

# computes weighted sum for patients in dataframe
computeWeightedSum <- function(X, orderList){
  # compute weight for each column in orderList
  weights <- magiqWeights(orderList)
  # compute weighted sum for each patient
  weightSum <- 0
  for (i in 1:length(orderList)){
    
    if (any(X[orderList[i]] == 'No' | X[orderList[i]] == 'Yes')){
      vector <- yes2one(X[orderList[i]])
    }
    else {
      vector <- X[orderList[i]]
    }
    weighted_vector <-standard_range(vector)*weights[i]
    weightSum <- weightSum + weighted_vector
  }
  return(weightSum)
}

computeWeightedSum(df,c('VLS', 'Cost'))


