library(shinyjqui)
library(DT)
library(shinythemes)

######################
# load & format data #
######################

toFactor <- function(x){
  return(as.factor(ifelse(as.logical(x) == TRUE, "Yes", "No")))
}


df <- read.csv('data/synthetic_patients.csv') %>%
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
         hospitalizationRisk = round(hospitalizationRisk, digits = 2)
  )
    

variables = colnames(df)[-c(1)]
variablesNamed <- c('Risk of Hospitalization', 'Substance Abuse', 'Alcohol Abuser', 'Lost to Care', 'CD4+ count', 'HbA1c measurement',
                    'Unstable Housing', 'Recent Missed Appointment', 'Newly Diagnosed HIV', 'Active HCV', 'High Cost Patient', 'Unmanaged Hypertension',
                    'Mental Health Disorder')

#########################
# prepare visualization #
#########################

patientColors <- c('#a1d99b', '#a2d89b', '#a4d89a', '#a5d79a', '#a6d799', '#a8d699', 
                   '#a9d598', '#aad598', '#abd498', '#add397', '#aed397', '#afd296', '#b0d196', 
                   '#b1d195', '#b3d095', '#b4d095', '#b5cf94', '#b6ce94', '#b7ce93', '#b8cd93', 
                   '#b9cc92', '#bacc92', '#bbcb92', '#bdca91', '#beca91', '#bfc990', '#c0c890', 
                   '#c1c88f', '#c2c78f', '#c3c68f', '#c4c68e', '#c5c58e', '#c6c48d', '#c7c48d', 
                   '#c8c38d', '#c9c28c', '#cac28c', '#cbc18b', '#ccc08b', '#cdc08a', '#cebf8a', 
                   '#cebe8a', '#cfbe89', '#d0bd89', '#d1bc88', '#d2bc88', '#d3bb87', '#d4ba87', 
                   '#d5ba87', '#d6b986', '#d7b886', '#d7b785', '#d8b785', '#d9b685', '#dab584', 
                   '#dbb584', '#dcb483', '#ddb383', '#ddb283', '#deb282', '#dfb182', '#e0b081', 
                   '#e1b081', '#e2af80', '#e2ae80', '#e3ad80', '#e4ad7f', '#e5ac7f', '#e6ab7e', 
                   '#e6aa7e', '#e7aa7e', '#e8a97d', '#e9a87d', '#e9a77c', '#eaa67c', '#eba67c', 
                   '#eca57b', '#eca47b', '#eda37a', '#eea37a', '#efa27a', '#efa179', '#f0a079', 
                   '#f19f78', '#f29f78', '#f29e78', '#f39d77', '#f49c77', '#f49b76', '#f59b76', 
                   '#f69a76', '#f79975', '#f79875', '#f89774', '#f99674', '#f99574', '#fa9573', 
                   '#fb9473', '#fb9372', '#fc9272')

gradientColors <- c('#a1d99b', '#aed397', '#b9cc93', '#c4c68e', '#cdbf8a', 
                    '#d6b986', '#dfb182', '#e7aa7e', '#eea27a', '#f59a76', '#fc9272')

cd4_brks <- quantile(df$CD4, probs = seq(.05, .95, .10), na.rm = TRUE)
hosp_risk_brks <- quantile(df$hospitalizationRisk, probs = seq(.05, .95, .10), na.rm = TRUE)
cost_brks <- quantile(df$Cost, probs = seq(.05, .95, .10), na.rm = TRUE)
hba1c_brks <- quantile(df$HbA1c, probs = seq(.05, .95, .10), na.rm = TRUE)

# generates list for dplyr::arrange
formatSort <- function(selectedOrder){
  myList <- c()
  # loop over each column in selectedOrder
  for(i in 1:length(selectedOrder)){
    myList <-c(myList, paste('desc(',selectedOrder[i],')', sep = ''))
  }
  # return unquoted objects
  return(
    print(as.name(paste(myList, collapse=', ')))
  )
}
    
##############
# create UI #
#############
    
ui <- fluidPage(theme = shinytheme("lumen"),
  h2("Who are my high-risk patients?"),
  
  sidebarLayout(
    sidebarPanel(width = 2,
  # add sidebarPanel,
      sortableCheckboxGroupInput("selectedVariables", "Indicators",
                                 choices = variables,
                                 selected = 'VLS'),
  selectInput("sortMethod", "Sorting Method:",
              c("No Sorting" = 'noSort',
                "Hard Sorting" = "hardSort",
                "Weighted Sorting" = "weightedSort")),
  checkboxInput("rankRows", "Rank Sort Patients", value = FALSE)
    ),
    mainPanel(
      DT::dataTableOutput("patientDF")
      )
  )
)

##################
# create server #
#################

server <- function(input, output) {
  
  output$order <- renderPrint({
    formatSort(
      input$selectedVariables_order[input$selectedVariables_order %in% input$selectedVariables]
    )
  })
  

  # data table
  output$patientDF = DT::renderDT(server=FALSE,{
    
    # retrieve only those columns in selection
    BinarySelection <- c('VLS', 'drugAbuse', 'etohAbuse', 'LTFU',
                   'UnstableHousing', 'MissedApt', 'NewDx', 'HCV',
                   'HTN', 'behavioralDx') %in% input$selectedVariables
    cd4Selection <- 'CD4' %in% input$selectedVariables
    costSelection <- 'Cost' %in% input$selectedVariables
    riskSelection <- 'hospitalizationRisk' %in% input$selectedVariables
    hbac1Selection <- 'HbA1c' %in% input$selectedVariables
    
    # plot data
      DT::datatable(
        df[-1,] 
          %>%  select(c('Name', input$selectedVariables_order[input$selectedVariables_order %in% input$selectedVariables])) 
         %>% arrange_at(
           input$selectedVariables_order[input$selectedVariables_order %in% input$selectedVariables],
           desc
         )
        ,
        filter = 'top',
        rownames = FALSE, 
        colnames = c(ID = 1),  # add the name 
        extensions = 'RowReorder',
        selection = 'none',
        autoHideNavigation = TRUE,
        options = list(fixedHeader = TRUE,
                       pageLength = 100,
                       rowReorder = TRUE)) %>%
        # add color to binary variables 
        formatStyle('ID', fontWeight = 'bold') %>%
        formatStyle(c('VLS', 'drugAbuse', 'etohAbuse', 'LTFU',
                      'UnstableHousing', 'MissedApt', 'NewDx', 'HCV',
                      'HTN', 'behavioralDx')[BinarySelection], 
                    backgroundColor = styleEqual(c('No', 'Yes'), c('#a1d99b', '#fc9272')), 
                    fontWeight = 'bold') %>%
        # add colors to continuous variables
        formatStyle(c('CD4')[cd4Selection], 
                    backgroundColor = styleInterval(cd4_brks, gradientColors), fontWeight = 'bold') %>%
        formatStyle(c('hospitalizationRisk')[riskSelection], 
                    backgroundColor = styleInterval(hosp_risk_brks, gradientColors), fontWeight = 'bold') %>%
        formatStyle(c('Cost')[costSelection], 
                    backgroundColor = styleInterval(cost_brks, gradientColors), fontWeight = 'bold') %>%
        formatStyle(c('HbA1c')[hbac1Selection], 
                    backgroundColor = styleInterval(hba1c_brks, gradientColors), fontWeight = 'bold') 
  })
}

shinyApp(ui, server)

