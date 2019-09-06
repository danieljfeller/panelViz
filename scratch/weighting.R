library(dplyr)
# converts a binary to Yes/No 
toFactor <- function(x){
  return(as.factor(ifelse(as.logical(x) == TRUE, "Yes", "No")))
}

# computes MAGIQ weights for an ordered list
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
  weights <- magiqWeights(selectedOrder)
  
  # compute weighted sum for each patient
  weightSum <- 0
  for (i in 1:length(selectedOrder)){
    weightSum <- weightSum + X[selectedOrder[i]]*weights[i]
  }
  
  return(weightSum)
}


df <- read.csv('synthetic_patients.csv') %>%
  mutate(VLS = toFactor(VLS),
         drugAbuse =toFactor(drugAbuse), 
         etohAbuse = toFactor(etohAbuse),
         LTFU = toFactor(LTFU),
         UnstableHousing = toFactor(UnstableHousing),
         MissedApt = toFactor(MissedApt),
         NewDx = toFactor(NewDx),
         HCV = toFactor(HCV),
         HTN = toFactor(HTN),
         behavioralDx = toFactor(behavioralDx),
         hospitalizationRisk = round(hospitalizationRisk, digits = 2))

raw_df <- read.csv('synthetic_patients.csv')

# get variable ranking
selectedOrder <- c("VLS", 'drugAbuse', 'hospitalizationRisk', 'UnstableHousing')
# get each patient's weighted sum
raw_df$weightRank <- computeWeightedSum(raw_df,selectedOrder)$VLS

testDF <- merge(df[-1,], raw_df[c('Name', 'weightRank')], by = 'Name')


# compute weight for each column in orderList
weights <- magiqWeights(selectedOrder)

# compute weighted sum for each patient
weightSum <- 0
for (i in 1:length(selectedOrder)){
  weightSum <- weightSum + X[selectedOrder[i]]*weights[i]
}



