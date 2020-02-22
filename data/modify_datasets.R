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
      # to increase prevalence by 20%, increase the number of 'TRUE's by 100
      if (x == FALSE & counter < 100) {
        replacement <- sample(c(TRUE,FALSE), size = 1)
        if (replacement == TRUE){counter = counter + 1}
        new_vector <- c(new_vector, replacement)
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
      replacement <- sample(c(TRUE,FALSE), size = 1)
      if (replacement == FALSE){counter = counter + 1}
      new_vector <- c(new_vector, replacement)
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

# alcohol abuse, depression, unstable housing, schizophrenia, chronic HCV, CKD, VLS
# CD4 count, office visits, inpatient admissions
panelViz_dataset <- read.csv('panelViz_dataset.csv')
panelViz_dataset <- shuffleDF(panelViz_dataset) %>% 
mutate(dx_alcoholism = divergeBinary(dx_alcoholism),
       dx_depression = divergeBinary(dx_depression),
       dx_unstable_housing = divergeBinary(dx_unstable_housing),
       dx_schizophrenia = divergeBinary(dx_schizophrenia),
       dx_hcv = divergeBinary(dx_hcv),
       dx_ckd = divergeBinary(dx_ckd),
       dx_hcv = divergeBinary(dx_hcv),
       vls = divergeBinary(vls),
       dx_hcv = divergeBinary(dx_hcv))

write.csv(panelViz_dataset, 'modified_panelViz_dataset.csv')


# drug abuse, axiety, new HIV dx, hypertension, cardiovascular disease, diabetes
# hbA1c, ER visits
baseline_dataset <- read.csv('baseline_dataset.csv')
baseline_dataset <- shuffleDF(baseline_dataset) %>% 
  mutate(dx_drug_abuse = divergeBinary(dx_drug_abuse),
         dx_anxiety = divergeBinary(dx_anxiety),
         new_dx = divergeBinary(new_dx),
         dx_hypertension = divergeBinary(dx_hypertension),
         dx_cardiovascular_disease = divergeBinary(dx_cardiovascular_disease),
         dx_diabetes = divergeBinary(dx_diabetes))

write.csv(baseline_dataset, 'modified_baseline_dataset.csv')


