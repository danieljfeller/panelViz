library(shinyjqui)
library(DT)

df <- read.csv('data/synthetic_patients.csv')
variables = colnames(df)[-c(1, 2)]
variablesNamed <- c('Risk of Hospitalization', 'Substance Abuse', 'Alcohol Abuser', 'Lost to Care', 'CD4+ count', 'HbA1c measurement',
                    'Unstable Housing', 'Recent Missed Appointment', 'Newly Diagnosed HIV', 'Active HCV', 'High Cost Patient', 'Unmanaged Hypertension',
                    'Mental Health Disorder')

ui <- basicPage(
  h2("Who are my high-risk patients?"),
  
  # add sidebarPanel
  orderInput('source', 'Care Indicators', items = variablesNamed,
             connect = 'dest', item_classs = 'warning'),
  orderInput('dest', 'High Risk Criteria', items = NULL, placeholder = 'Drag items here...'),
  verbatimTextOutput('order'),
  
  DT::dataTableOutput("mytable")
)

server <- function(input, output) {
  output$mytable = DT::renderDT(server=FALSE,{
    DT::datatable(
      df, colnames = c(ID = 1),  # add the name 
      extensions = 'RowReorder',
      selection = 'none',
      options = list(order = list(list(0, 'asc')), rowReorder = TRUE)) # sort by ID
  })
}

shinyApp(ui, server)

