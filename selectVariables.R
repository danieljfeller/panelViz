library(shinyjqui)
library(DT)

######################
# load & format data #
######################


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

#########################
# prepare visualization #
#########################

gradientColors <- c('#E5F5E0','#E7F3DD','#EAF2DB','#ECF1D8','#EFEFD6','#F1EED4',
                    '#F4EDD1','#F6EBCF','#F9EACC','#FBE9CA','#FEE8C8')

cd4_brks <- quantile(df$CD4, probs = seq(.05, .95, .10), na.rm = TRUE)
hosp_risk_brks <- quantile(df$hospitalizationRisk, probs = seq(.05, .95, .10), na.rm = TRUE)
cost_brks <- quantile(df$Cost, probs = seq(.05, .95, .10), na.rm = TRUE)
hba1c_brks <- quantile(df$HbA1c, probs = seq(.05, .95, .10), na.rm = TRUE)
    
##############
# create UI #
#############
    
ui <- basicPage(
  h2("Who are my high-risk patients?"),
  
  sidebarLayout(
    sidebarPanel(width = 2,
  # add sidebarPanel
      sortableCheckboxGroupInput("selectedVariables", "Indicators",
                                 choices = variables)
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
        df[-1,] %>% select(c('Name', input$selectedVariables)),
        rownames = FALSE, 
        colnames = c(ID = 1),  # add the name 
        extensions = 'RowReorder',
        selection = 'none',
        autoHideNavigation = TRUE,
        options = list(pageLength = 100,
                       order = list(list(0, 'asc')), 
                       rowReorder = TRUE)) %>%
        # add color to binary variables
        formatStyle(c('VLS', 'drugAbuse', 'etohAbuse', 'LTFU',
                      'UnstableHousing', 'MissedApt', 'NewDx', 'HCV',
                      'HTN', 'behavioralDx')[BinarySelection], 
                    backgroundColor = styleEqual(c('No', 'Yes'), c('#e5f5e0', '#fee8c8')), 
                    fontWeight = 'bold') %>%
        # add colors to continuous variables
        formatStyle(c('CD4')[cd4Selection], 
                    backgroundColor = styleInterval(cd4_brks, gradientColors)) %>%
        formatStyle(c('hospitalizationRisk')[riskSelection], 
                    backgroundColor = styleInterval(hosp_risk_brks, gradientColors)) %>%
        formatStyle(c('Cost')[costSelection], 
                    backgroundColor = styleInterval(cost_brks, gradientColors)) %>%
        formatStyle(c('HbA1c')[hbac1Selection], 
                    backgroundColor = styleInterval(hba1c_brks, gradientColors)) 
  })
}

shinyApp(ui, server)

