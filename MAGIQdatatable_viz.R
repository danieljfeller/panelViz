# data table
output$patientDF = DT::renderDT(server=FALSE,{
  
  # retrieve only those columns in selection
  BinarySelection <- c('VLS', 'drugAbuse', 'etohAbuse', 'DM',
                       'UnstableHousing', 'NewDx', 'HCV', 'CVD', 'CKD',
                       'HTN', 'Depression', 'Anxiety','Schizophrenia') %in% input$selected
  cd4Selection <- 'cd4' %in% input$selected
  HbA1cSelection <- 'hba1c' %in% input$selected
  
  officeSelection <- 'office_visits' %in% input$selected
  erSelection <- 'er_visits' %in% input$selected
  inpatientSelection <- 'inpatient_admissions' %in% input$selected
  
  # get MAGIQ score (rankings) for each patient
  raw_df <- read.csv('data/ehr_dataset.csv')
  MAGIQscore <- computeWeightedSum(raw_df, input$selected)
  raw_df$weightRank <- MAGIQscore[,1]
  
  # get quantiles for patient rank
  patient_brks <- quantile(as.numeric(row.names(df)), probs = seq(0, 1, .01))
  
  #########################
  # select sorting method #
  #########################
  
  DT::datatable(
    # don't sort data
    if (input$sortMethod == 'noSort'){
      df %>% 
        select(c('Name', input$selected)) %>%
        tibble::rownames_to_column()
    }
    # sort data deterministicly
    else if (input$sortMethod == 'hardSort') {
      df %>%  
        select(c('Name', input$selected)) %>% 
        arrange_at(
          input$selected,
          desc) %>%
        tibble::rownames_to_column()
    }
    # use MAGIQ weighting
    else {
      merge(df, raw_df[c('Name', 'weightRank')], by = 'Name') %>% 
        arrange(desc(weightRank)) %>%
        select(c('Name', input$selected)) %>%
        tibble::rownames_to_column()
    },
    
    ###################
    # format DT table #
    ###################
    
    filter = 'top',
    rownames = FALSE, 
    extensions = 'RowReorder',
    selection = 'none',
    autoHideNavigation = TRUE,
    options = list(fixedHeader = TRUE,
                   pageLength = 500,
                   columnDefs = list(list(visible=FALSE, targets=c(0))),
                   rowReorder = TRUE)) %>%
    
    # add color to binary variables 
    formatStyle(c('VLS', 'drugAbuse', 'etohAbuse', 'DM',
                  'UnstableHousing', 'NewDx', 'HCV', 'CVD', 'CKD',
                  'HTN', 'Depression', 'Anxiety','Schizophrenia')[BinarySelection], 
                backgroundColor = styleEqual(c('No', 'Yes'), c('#a1d99b', '#fc9272')), 
                color = 'white',
                fontWeight = 'bold') %>%
    
    # add colors to continuous variables
    formatStyle(c('cd4')[cd4Selection], 
                backgroundColor = styleInterval(cd4_brks, gradientColors), 
                color = 'white',
                fontWeight = 'bold') %>%
    formatStyle(c('hba1c')[HbA1cSelection], 
                backgroundColor = styleInterval(hba1c_brks, gradientColors), 
                color = 'white',
                fontWeight = 'bold') %>%
    formatStyle(c('office_visits')[officeSelection], 
                backgroundColor = styleInterval(office_brks, gradientColors), 
                color = 'white',
                fontWeight = 'bold') %>%
    formatStyle(c('er_visits')[erSelection], 
                backgroundColor = styleInterval(er_brks, gradientColors), 
                color = 'white',
                fontWeight = 'bold') %>%
    formatStyle(c('inpatient_admissions')[inpatientSelection], 
                backgroundColor = styleInterval(inpatient_brks, gradientColors), 
                color = 'white',
                fontWeight = 'bold') %>%
    
    # add color to patient names
    formatStyle('Name','rowname', 
                backgroundColor = styleInterval(patient_brks, patientColors), 
                color = 'white',
                fontWeight = 'bold')
})