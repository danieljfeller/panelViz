library(shinydashboard)
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

variables <- c('Viral Load', 'Risk of Hospitalization', 'Substance Abuse', 'Alcohol Abuse', 'Lost to Care', 'CD4+ count', 'Diabetes',
                    'Unstable Housing', 'Recent Missed Appointment', 'Newly Diagnosed HIV', 'Active HCV', 'High Cost Patient', 'Unmanaged Hypertension',
                    'Mental Health Disorder')

ui <- dashboardPage(
  ## header content
  dashboardHeader(title = "panelViz"),
  ## Sidebar content
  dashboardSidebar(
    # visualization modalities
    sidebarMenu(
      menuItem("My Panel Overview", tabName = "hexplot", icon = icon("globe")),
      menuItem("My Care Gaps", tabName = "table", icon = icon("exclamation-circle")))),
  # dasboard body
  dashboardBody(
    # prioritization criteria
    box(title = 'Prioriziation Criteria', status = "primary", solidHeader = TRUE, collapsible = TRUE,
    bucket_list(
      header = "",
      group_name = "bucket_list_group",
      orientation = "vertical",
      add_rank_list(
        text = "Prioritization Criteria",
        labels = c("VLS", "hospitalizationRisk"),
        input_id = "selected"),
      add_rank_list(
        text = 'Select & Drag Variables',
        labels = variables[variables != 'VLS' & variables != 'hospitalizationRisk'],
        input_id = "unselected")))))
        


server <- function(input, output, session){}

shinyApp(ui, server)