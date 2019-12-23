
ui <- dashboardPage(
## header content
dashboardHeader(title = "panelViz"),
## Sidebar content
dashboardSidebar(
  # visualization modalities
  sidebarMenu(
    menuItem("My Panel Overview", tabName = "hexplot", icon = icon("globe")),
    menuItem("My Care Gaps", tabName = "table", icon = icon("exclamation-circle"))),
  # prioritization criteria
    menuItem(
                   bucket_list(
                   header = "Select High-Risk Criteria",
                   group_name = "bucket_list_group",
                   orientation = "vertical",
                   add_rank_list(
                     text = "Prioritization Criteria",
                     labels = c("VLS", "hospitalizationRisk"),
                     input_id = "selected"
                   ),
                   add_rank_list(
                     text = 'Select & Drag Variables',
                     labels = variables[variables != 'VLS' & variables != 'hospitalizationRisk'],
                     input_id = "unselected"
                   )
                 ),
                 selectInput("sortMethod", "Sorting Method:",
                             c("No Sorting" = 'noSort',
                               "Hard Sorting" = "hardSort",
                               "Weighted Sorting" = "weightedSort"),
                             selected = 'weightedSort'))),
# dasboard body
dashboardBody(
  # First tab content
  tabItems(
    # hexplot
    tabItem(tabName = "hexplot",
            fluidRow(
              # hexagon plot
              box(plotOutput("hex_plot", hover = "plot_hover", hoverDelay = 0)),
              # valueBox with patient name
              valueBoxOutput("nameBox")
              box(uiOutput("dynamic"))),
    
    ,
    )
    
    # Second tab content
    tabItem(tabName = "table",
            h2("Widgets tab content")),
    # Third tab content
    tabItem(tabName = "table",
            h2("Widgets tab content"))
    )
  )
)


server <- function(input, output, session){
  
  
  
}

shinyApp(ui, server)