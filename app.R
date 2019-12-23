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

# computes MAGIQ weights for an ordered list of column names
magiqWeights <- function(list){
    weights <- c()
    for (i in 1:length(list)){
        weights[i] <- (1/i)/length(list)
    }
    return(weights)
}

# computes weighted sum for patients in dataframe
computeWeightedSum <- function(X, orderList){
    # compute weight for each column in orderList
    weights <- magiqWeights(orderList)
    # compute weighted sum for each patient
    weightSum <- 0
    for (i in 1:length(orderList)){
        
        if (any(X[orderList[i]] == 'No' | X[orderList[i]] == 'Yes')){
            vector <- yes2one(X[orderList[i]])
        }
        else {
            vector <- X[orderList[i]]
        }
        weighted_vector <-standard_range(vector)*weights[i]
        weightSum <- weightSum + weighted_vector
    }
    return(weightSum)
}

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

###############################
# format data for hexbin plot #
###############################

df$rank <- row_number(df$Name)
df$j <- 1
df$i <- 1

counter = 0
offset <- 0.5 #offset for the hexagons when moving up a row
for (row in 1:22){
    # change offset when increasing rows
    offset <- ifelse(offset == 0.5, 0, 0.5)
    for (column in 1:22){
        counter <- counter + 1
        df[df$rank == counter,]$i <- row
        df[df$rank == counter,]$j <- column + offset
    }
}

#########################
# prepare visualization #
#########################

patientColors <- c('#fc9272', '#fa9473', '#f89574', '#f69775', '#f49876', '#f29a76', '#f19b77', 
                   '#ef9c78', '#ee9d78', '#ec9e79', '#eba07a', '#e9a17a', '#e8a27b', '#e7a37c', 
                   '#e5a47c', '#e4a57d', '#e3a67d', '#e2a67e', '#e1a77e', '#dfa87f', '#dea97f', 
                   '#ddaa80', '#dcab80', '#dbac81', '#daac81', '#d9ad82', '#d8ae82', '#d7af83', 
                   '#d6b083', '#d5b083', '#d4b184', '#d3b284', '#d2b385', '#d1b385', '#d1b486', 
                   '#d0b586', '#cfb586', '#ceb687', '#cdb787', '#ccb788', '#cbb888', '#cab988', 
                   '#cab989', '#c9ba89', '#c8ba89', '#c7bb8a', '#c6bc8a', '#c6bc8a', '#c5bd8b', 
                   '#c4be8b', '#c3be8c', '#c3bf8c', '#c2bf8c', '#c1c08d', '#c0c18d', '#bfc18d', 
                   '#bfc28e', '#bec28e', '#bdc38e', '#bcc48f', '#bcc48f', '#bbc58f', '#bac590', 
                   '#bac690', '#b9c690', '#b8c790', '#b8c791', '#b7c891', '#b6c991', '#b5c992', 
                   '#b5ca92', '#b4ca92', '#b3cb93', '#b3cb93', '#b2cc93', '#b1cc94', '#b1cd94', 
                   '#b0cd94', '#afce95', '#afce95', '#aecf95', '#aecf95', '#add096', '#acd096', 
                   '#acd196', '#abd197', '#aad297', '#aad297', '#a9d397', '#a8d398', '#a8d498', 
                   '#a7d498', '#a6d599', '#a6d599', '#a5d699', '#a5d699', '#a4d79a', '#a3d79a', 
                   '#a3d89a', '#a2d89a', '#a2d99b', '#a1d99b')

gradientColors <- c('#a1d99b', '#aed397', '#b9cc93', '#c4c68e', '#cdbf8a', 
                    '#d6b986', '#dfb182', '#e7aa7e', '#eea27a', '#f59a76', '#fc9272')

ColRamp <- rev(designer.colors(n=10, col=brewer.pal(9, "Spectral")))

# quantiles for all numeric variables
cd4_brks <- quantile(df$CD4, probs = seq(.05, .95, .10), na.rm = TRUE)
hosp_risk_brks <- quantile(df$hospitalizationRisk, probs = seq(.05, .95, .10), na.rm = TRUE)
cost_brks <- quantile(df$Cost, probs = seq(.05, .95, .10), na.rm = TRUE)

#############
# create UI #
#############

ui <- fluidPage(theme = shinytheme("sandstone"),
                
                sidebarLayout(
    
                    #######################
                    # table visualization #
                    #######################
                    
                    mainPanel(
                        tabsetPanel(
                            tabPanel("Overview", 
                                     plotOutput("hex_plot", hover = "plot_hover", hoverDelay = 0),
                                     htmlOutput("dynamic")),
                            tabPanel("Rank", 
                                     DT::dataTableOutput("patientDF")),
                            tabPanel("Group", 
                                     sliderInput("clusters",
                                                 label = "Clusters",
                                                 min = 1,
                                                 max = 25,
                                                 value = 9),
                                     d3heatmapOutput("heatmap",
                                                              height = 600,
                                                              width = 800)
                                     )
                    )
                ),
                #######################
                # interaction widgets #
                #######################
                
                sidebarPanel(width = 4,
                             # add sidebarPanel,
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
                                         selected = 'weightedSort')
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
    
    newData <- reactive({
        # get MAGIQ score (rankings) for each patient
        ordered_selected_Variables <- input$selectedVariables_order[input$selectedVariables_order %in% input$selectedVariables]
        MAGIQscore <- computeWeightedSum(df, ordered_selected_Variables)
        df$weightRank <- MAGIQscore[,1]
        print(df)
    })
    
    # data table
    output$patientDF = DT::renderDT(server=FALSE,{
        
        # retrieve only those columns in selection
        BinarySelection <- c('VLS', 'drugAbuse', 'etohAbuse', 'LTFU', 'DM',
                             'UnstableHousing', 'MissedApt', 'NewDx', 'HCV',
                             'HTN', 'MentalHealth') %in% input$selected
        cd4Selection <- 'CD4' %in% input$selected
        costSelection <- 'Cost' %in% input$selected
        riskSelection <- 'hospitalizationRisk' %in% input$selected

        # get MAGIQ score (rankings) for each patient
        raw_df <- read.csv('data/synthetic_patients.csv')
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
            formatStyle(c('VLS', 'drugAbuse', 'etohAbuse', 'LTFU', 'DM',
                          'UnstableHousing', 'MissedApt', 'NewDx', 'HCV',
                          'HTN', 'MentalHealth')[BinarySelection], 
                        backgroundColor = styleEqual(c('No', 'Yes'), c('#a1d99b', '#fc9272')), 
                        color = 'white',
                        fontWeight = 'bold') %>%
            
            # add colors to continuous variables
            formatStyle(c('CD4')[cd4Selection], 
                        backgroundColor = styleInterval(cd4_brks, gradientColors), 
                        color = 'white',
                        fontWeight = 'bold') %>%
            formatStyle(c('hospitalizationRisk')[riskSelection], 
                        backgroundColor = styleInterval(hosp_risk_brks, gradientColors), 
                        color = 'white',
                        fontWeight = 'bold') %>%
            formatStyle(c('Cost')[costSelection], 
                        backgroundColor = styleInterval(cost_brks, gradientColors), 
                        color = 'white',
                        fontWeight = 'bold') %>%
            
            # add color to patient names
            formatStyle('Name','rowname', 
                        backgroundColor = styleInterval(patient_brks, patientColors), 
                        color = 'white',
                        fontWeight = 'bold')
    })
    
    ###########
    # heatmap #
    ###########
    
    output$heatmap <- renderD3heatmap({
        d3heatmap(rawDF %>% select(input$selected), 
                  scale = "none",
                  dendrogram = 'row',
                  labRow = pt.names,
                  color = c('#a1d99b', '#fc9272'),
                  k_row = input$clusters)
    })
    
    #############
    # hex plot #
    ############
    
    output$hex_plot <- renderPlot({
        
        # get MAGIQ score (rankings) for each patient
        MAGIQscore <- computeWeightedSum(df, input$selected)
        df$weightRank <- MAGIQscore[,1]

        ggplot(data = df, aes(x=i, y=j, fill = weightRank))+
            geom_hex(stat='identity')+
            scale_fill_gradientn(colours = ColRamp)+
            theme_bw()+
            theme(aspect.ratio = 0.5)+
            coord_flip()
        })
    
    # retrieve values to be reactively presented in UI
    output$vals <- renderPrint({
        # retrieve coordinates from user's cursor
        hover <- input$plot_hover 
        # returns row from dataframe hover coordinators
        df <- nearPoints(df, hover, threshold = 10)
        c('')
        print(df)
    })
    
    # renders reactive output variable 
    output$dynamic <- renderUI({
        # only proceed if mouse coordinates exist
        req(input$plot_hover) 
        verbatimTextOutput("vals")
    })
}

#####################
# run the shiny app #
#####################

shinyApp(ui = ui, server = server)
