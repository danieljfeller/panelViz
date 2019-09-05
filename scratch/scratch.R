
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
         behavioralDx = ifelse(as.logical(behavioralDx) == TRUE, "Yes", "No"),
         hospitalizationRisk = round(hospitalizationRisk, digits = 2)
  )


patientColors <- c('#fc9272', '#fb9372', '#fb9473', '#fa9573', '#f99574', '#f99674', '#f89774', 
                   '#f79875', '#f79975', '#f69a76', '#f59b76', '#f49b76', '#f49c77', '#f39d77', 
                   '#f29e78', '#f29f78', '#f19f78', '#f0a079', '#efa179', '#efa27a', '#eea37a', 
                   '#eda37a', '#eca47b', '#eca57b', '#eba67c', '#eaa67c', '#e9a77c', '#e9a87d', 
                   '#e8a97d', '#e7aa7e', '#e6aa7e', '#e6ab7e', '#e5ac7f', '#e4ad7f', '#e3ad80', 
                   '#e2ae80', '#e2af80', '#e1b081', '#e0b081', '#dfb182', '#deb282', '#ddb283', 
                   '#ddb383', '#dcb483', '#dbb584', '#dab584', '#d9b685', '#d8b785', '#d7b785', 
                   '#d7b886', '#d6b986', '#d5ba87', '#d4ba87', '#d3bb87', '#d2bc88', '#d1bc88', 
                   '#d0bd89', '#cfbe89', '#cebe8a', '#cebf8a', '#cdc08a', '#ccc08b', '#cbc18b', 
                   '#cac28c', '#c9c28c', '#c8c38d', '#c7c48d', '#c6c48d', '#c5c58e', '#c4c68e', 
                   '#c3c68f', '#c2c78f', '#c1c88f', '#c0c890', '#bfc990', '#beca91', '#bdca91', 
                   '#bbcb92', '#bacc92', '#b9cc92', '#b8cd93', '#b7ce93', '#b6ce94', '#b5cf94', 
                   '#b4d095', '#b3d095', '#b1d195', '#b0d196', '#afd296', '#aed397', '#add397', 
                   '#abd498', '#aad598', '#a9d598', '#a8d699', '#a6d799', '#a5d79a', '#a4d89a', 
                   '#a2d89b', '#a1d99b')

ID_brks <- quantile(as.numeric(rownames(df)), probs = seq(.01, .99, .01), na.rm = TRUE)
df$ID <- as.numeric(rownames(df))

DT::datatable(
  df,
  rownames = FALSE, 
  #colnames = c(ID = 1),  # add the name 
  extensions = 'RowReorder',
  selection = 'none',
  autoHideNavigation = TRUE,
  options = list(fixedHeader = TRUE,
                 pageLength = 100,
                 rowReorder = TRUE)) %>%
  formatStyle(columns = 'Name', 
              valueColumns = 'ID',
              fontWeight = 'bold',
              backgroundColor = styleInterval(ID_brks, patientColors))
  
