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

rawDF <- read.csv('data/baseline_dataset.csv')

df <- read.csv('data/baseline_dataset.csv', fill = TRUE) %>%
  mutate(Name = name,
         VLS = toFactor(vls),
         DM = toFactor(dx_diabetes),
         DrugAbuse =toFactor(dx_alcoholism), 
         AlcoholAbuse = toFactor(dx_drug_abuse),
         UnstableHousing = toFactor(unstable_housing),
         NewDx = toFactor(new_dx),
         HCV = toFactor(dx_hcv),
         HTN = toFactor(dx_hypertension),
         CVD = toFactor(dx_cardiovascular.disease),
         CKD = toFactor(dx_ckd),
         Depression = toFactor(dx_depression),
         Anxiety = toFactor(dx_anxiety),
         Schizophrenia = toFactor(dx_schizophrenia),
         OfficeVisits = office_visits,
         ERvisits = er_visits,
         InpatientAdmits = inpatient_admissions,
         HbA1c = hba1c,
         CD4count = cd4
  )

# remove duplicate patients
df <- df[!duplicated(df),]

# care indiciators for the tool
df <- df[,c('Name',"VLS","DM","DrugAbuse","AlcoholAbuse","UnstableHousing","NewDx","HCV","HTN","CVD",
            "CKD","Depression","Anxiety","Schizophrenia","HbA1c", "CD4count", "OfficeVisits", "ERvisits", 
            "InpatientAdmits")]

# shuffle order of dataframe
df <- df[sample(nrow(df)), ]

# get all cvariable names (excluding name)
variables = colnames(df)[-c(1:length(colnames))]

names(variables) <- c('Virally Suppressed', 'Diabetes', 'Active Drug Use', 'Alcoholism', 'Unstable Housing', 'New HIV Diagnosis',
  'Chronic HCV', 'Hypertension', 'Cardiovascular Disease', 'Chronic Kidney Disease', 'Major Depression', 
  'Anxiety Disorder', 'Schizophrenia', 'Most recent HbA1c value', 'Most recent CD4 count', '# Office visits',
  '# Emergency Room visits', '# Inpatient admissions')

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
      selectInput("selected_variables", label = h3("Select Care Gap"), 
                  choices = names(variables), 
                  selected = 1)),
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

server <- function(input, output) {
  
  ####################
  # get updated data #
  ####################
  
  
  # data table
  output$patientDF = DT::renderDT(

    #########################
    # select sorting method #
    #########################
    
    DT::datatable( 
      data = df %>% select(c('Name', variables[input$selected_variables])) %>% tibble::rownames_to_column(),
      rownames = FALSE, 
      extensions = 'RowReorder',
      selection = 'none',
      autoHideNavigation = TRUE,
      options = list(fixedHeader = FALSE,
                     pageLength = 500,
                     columnDefs = list(list(visible=FALSE, targets=c(0))),
                     rowReorder = TRUE))
  )
}
  
#####################
# run the shiny app #
#####################

shinyApp(ui = ui, server = server)
