library(shinyjqui)
library(DT)

df <- read.csv('../data/synthetic_patients.csv')
variables = colnames(df)[-c(1, 2)]

ui <- basicPage(
  h2("My Patient Panel"),
  
  # add sidebarPanel
  # add orderInput on 'variables'
  
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

