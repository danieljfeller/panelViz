library(shinyjqui)
library(DT)

df <- read.csv('data/synthetic_patients.csv') %>%
  mutate(suppressed_viral_load = ifelse(as.logical(suppressed_viral_load) == TRUE, "Yes", "No"),
         substance_abuser = ifelse(as.logical(substance_abuser) == TRUE, "Yes", "No"), 
         alcohol_abuser = ifelse(as.logical(alcohol_abuser) == TRUE, "Yes", "No"),
         lost_to_care = ifelse(as.logical(lost_to_care) == TRUE, "Yes", "No"),
         unstably_housed = ifelse(as.logical(unstably_housed) == TRUE, "Yes", "No"),
         misses_appointments = ifelse(as.logical(misses_appointments) == TRUE, "Yes", "No"),
         new_patient = ifelse(as.logical(new_patient) == TRUE, "Yes", "No"),
         active_hcv = ifelse(as.logical(active_hcv) == TRUE, "Yes", "No"),
         hypertension = ifelse(as.logical(hypertension) == TRUE, "Yes", "No"),
         mental_health_disorder = ifelse(as.logical(mental_health_disorder) == TRUE, "Yes", "No")
  )
    
    
    
variables = colnames(df)[-c(1)]
variablesNamed <- c('Risk of Hospitalization', 'Substance Abuse', 'Alcohol Abuser', 'Lost to Care', 'CD4+ count', 'HbA1c measurement',
                    'Unstable Housing', 'Recent Missed Appointment', 'Newly Diagnosed HIV', 'Active HCV', 'High Cost Patient', 'Unmanaged Hypertension',
                    'Mental Health Disorder')

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

server <- function(input, output) {
  
  # data table
  output$patientDF = DT::renderDT(server=FALSE,{
    DT::datatable(
      df %>% 
        select(c('patient', input$selectedVariables)),
      colnames = c(ID = 1),  # add the name 
      extensions = 'RowReorder',
      selection = 'none',
      options = list(order = list(list(0, 'asc')), 
                     rowReorder = TRUE,
                     autoWidth = TRUE,
                     columnDefs = list(list(width = '100px', targets = "_all"))) 
      )
  })
}

shinyApp(ui, server)

