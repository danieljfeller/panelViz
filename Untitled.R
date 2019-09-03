library(shinyjqui)
library(DT)

df <- read.csv('data/synthetic_patients.csv') %>%
  mutate(VLS = ifelse(as.logical(VLS) == TRUE, "Yes", "No"),
         drugAbuse = ifelse(as.logical(drugAbuse) == TRUE, "Yes", "No"), 
         etohAbuse = ifelse(as.logical(etohAbuse) == TRUE, "Yes", "No"),
         LTFU = ifelse(as.logical(LTFU) == TRUE, "Yes", "No"),
         UnstableHousing = ifelse(as.logical(UnstableHousing) == TRUE, "Yes", "No"),
         MissedApt = ifelse(as.logical(MissedApt) == TRUE, "Yes", "No"),
         NewDx = ifelse(as.logical(NewDx) == TRUE, "Yes", "No"),
         HCV = ifelse(as.logical(HCV) == TRUE, "Yes", "No"),
         HTN = ifelse(as.logical(HTN) == TRUE, "Yes", "No"),
         behavioralDx = ifelse(as.logical(behavioralDx) == TRUE, "Yes", "No")
  )



variables = colnames(df)[-c(1)]
variablesNamed <- c('Risk of Hospitalization', 'Substance Abuse', 'Alcohol Abuser', 'Lost to Care', 'CD4+ count', 'HbA1c measurement',
                    'Unstable Housing', 'Recent Missed Appointment', 'Newly Diagnosed HIV', 'Active HCV', 'High Cost Patient', 'Unmanaged Hypertension',
                    'Mental Health Disorder')
 
DT::datatable(
  
  df %>% select(c('Name', variables)),
  
  colnames = c(ID = 1),  # add the name 
  
  extensions = 'RowReorder',
  
  selection = 'none',
  
  options = list(order = list(list(0, 'asc')), 
                 rowReorder = TRUE)) %>%
  
  formatStyle(c('VLS', 'drugAbuse', 'etohAbuse', 'LTFU',
                'UnstableHousing', 'MissedApt', 'NewDx', 'HCV',
                'HTN', 'behavioralDx'), 
              backgroundColor = styleEqual(c('No', 'Yes'), c('#deebf7', '#fee8c8')), 
              fontWeight = 'bold')







