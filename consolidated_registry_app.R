library(shinyjqui)
library(DT)
library(shinythemes)
library(dplyr)
library(d3heatmap)
library(ggplot2)
library(plotly)
library(fields)
library(RColorBrewer)
library(sortable)

####################
# define functions #
####################

# convert logical vector to character
toFactor <- function(x){
  return(as.factor(ifelse(as.logical(x) == TRUE, "Yes", "No")))
}

# range standardization
standard_range <- function(x){
  (x-min(x))/(max(x)-min(x))
}

# converts Yes/No to 1/0
yes2one <- function(x){
  return(ifelse(x =='Yes', 1, 0))
}



######################
# load & format data #
######################
rawDF <- read.csv('data/synthetic_patients.csv')[1:500,]
pt.names <- rawDF$Name

df <- read.csv('data/synthetic_patients.csv', fill = TRUE) %>%
  mutate(VLS = toFactor(VLS),
         DM = toFactor(DM),
         drugAbuse =toFactor(drugAbuse), 
         etohAbuse = toFactor(etohAbuse),
         LTFU = toFactor(LTFU),
         UnstableHousing = toFactor(UnstableHousing),
         MissedApt = toFactor(MissedApt),
         NewDx = toFactor(NewDx),
         HCV = toFactor(HCV),
         HTN = toFactor(HTN),
         MentalHealth = toFactor(MentalHealth),
         hospitalizationRisk = round(hospitalizationRisk, digits = 2))
df <- df[!duplicated(df),]

variables = colnames(df)[-c(1,16)]
variablesNamed <- c('Viral Load', 'Risk of Hospitalization', 'Substance Abuse', 'Alcohol Abuse', 'Lost to Care', 'CD4+ count', 'Diabetes',
                    'Unstable Housing', 'Recent Missed Appointment', 'Newly Diagnosed HIV', 'Active HCV', 'High Cost Patient', 'Unmanaged Hypertension',
                    'Mental Health Disorder')

#############
# create UI #
#############

ui <- fluidPage(
  # App title ----
  titlePanel("My Panel"),
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    # Sidebar panel for inputs ----
    sidebarPanel(
      # Input: Slider for the number of bins ----
      sortableCheckboxGroupInput("selected_variables", label = h3("Select Care Gaps"), 
                         choices = names(df)[2:length(names(df))],
                         selected = c('Viral Load'))),
    # Main panel for displaying outputs ----
    mainPanel(
      # Output: interactive table
      DT::dataTableOutput("patientDF")
    )
  )
)

##################
# create server #
#################

server <- function(input, output){
  
  ####################
  # get updated data #
  ####################
  
  # data table
  output$patientDF = DT::renderDT(server=FALSE,{

    ordered_selected_variables <- input$selected_variables_order[input$selected_variables_order %in% input$selected_variables]
    
    #########################
    # select sorting method #
    #########################
    
    DT::datatable( 
      data = df %>% 
        select(c('Name', input$selected_variables)) %>% 
        arrange_at(
          ordered_selected_variables,
          desc) %>%
        tibble::rownames_to_column(),
      rownames = FALSE, 
      extensions = 'RowReorder',
      selection = 'none',
      autoHideNavigation = TRUE,
      options = list(fixedHeader = FALSE,
                     pageLength = 500,
                     columnDefs = list(list(visible=FALSE, targets=c(0))),
                     rowReorder = TRUE))
  })
}
  
#####################
# run the shiny app #
#####################

shinyApp(ui = ui, server = server)
