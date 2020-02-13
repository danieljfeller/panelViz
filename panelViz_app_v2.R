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
library(shinydashboard)
library(shinyWidgets)

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

# converts Yes/No to 1/0
yes2zero <- function(x){
    return(ifelse(x =='Yes', 0, 1))
}

# computes MAGIQ weights for an ordered list of arbitrary length
magiqWeights <- function(list){
    weights <- c()
    for (i in 1:length(list)){
        weights[i] <- (1/i)/length(list)
    }
    return(weights)
}

# computes weighted sum for patients in dataframe
computeWeightedSum <- function(X, orderList){
    
    # computes MAGIQ weights for an ordered list of arbitrary length
    weights <- magiqWeights(orderList)
    
    # compute weighted sum for each patient
    weightSum <- 0
    
    # for each variable in orderList
    for (i in 1:length(orderList)){
        
        # isolate & normalize variable
        if (orderList[i] %in% c("DM","DrugAbuse","AlcoholAbuse","UnstableHousing","NewDx","HCV","HTN","CVD",
                                "CKD","Depression","Anxiety","Schizophrenia")){
            vector <- yes2one(X[orderList[i]])
        } else if (orderList[i] %in% c("VLS")){
            vector <- yes2zero(X[orderList[i]])
        } else if (orderList[i] %in% c("OfficeVisits", "CD4count")){
            vector = 1- (ntile(X[orderList[i]], 100)/100)
        } else if (orderList[i] %in% c("ERvisits","InpatientAdmits", "HbA1c")){
            vector = ntile(X[orderList[i]], 100)/100
        } else {
            print(paste(orderList[i], "-", "variable error"))
            vector <- X[orderList[i]]
        }
        
        # multiply normalized varible by respective MAGIQ weight
        weighted_vector <-standard_range(vector)*weights[i]
        
        # add normalized weighted vector to priority score 
        weightSum <- weightSum + weighted_vector
    }
    
    # bizarre behavior for encounter variables; this fixes bug
    if (is.null(dim(weightSum))) {
        return(weightSum)
    } else {
        return(weightSum[,1])
        }
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

rawDF <- read.csv('data/panelViz_dataset.csv')

df <- read.csv('data/panelViz_dataset.csv', fill = TRUE) %>%
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

###############################
# format data for hexbin plot #
###############################

hexPosition <- function(df){
    df$rank <- rank(-df$weightRank, ties.method = 'first')
    df$j <- 0
    df$i <- 0
    
    counter = 0
    offset <- 0.5 #offset for the hexagons when moving up a row
    for (row in 22:1){
        # change offset when increasing rows
        offset <- ifelse(offset == 0.5, 0, 0.5)
        for (column in 1:22){
            counter <- counter + 1
            df[df$rank == counter,]$i <- row
            df[df$rank == counter,]$j <- column + offset
        }
    }
    # return unquoted objects
    return(df %>% subset(rank < 485))
}



#########################
# prepare visualization #
#########################

ColRamp <- rev(designer.colors(n=10, col=brewer.pal(9, "Spectral")))

# quantiles for all numeric variables
CD4count_brks <- quantile(df$CD4count, probs = seq(.05, .95, .10), na.rm = TRUE)
HbA1c_brks <- quantile(df$HbA1c, probs = seq(.05, .95, .10), na.rm = TRUE)

office_brks <- quantile(df$OfficeVisits, probs = seq(.05, .95, .10), na.rm = TRUE)
er_brks <- quantile(df$ERvisits, probs = seq(.05, .95, .10), na.rm = TRUE)
inpatient_brks <- quantile(df$InpatientAdmits, probs = seq(.05, .95, .10), na.rm = TRUE)

#############
# create UI #
#############


ui <- fluidPage(theme = shinytheme("sandstone"),
                
                fluidRow(
                    #######################
                    # table visualization #
                    #######################
                        tabsetPanel(
                            tabPanel("Overview",
                                     column(width = 2,
                                            br(),
                                            # user-controlled prioritization
                                            dropdownButton(
                                                # select prioritization criteria
                                                bucket_list(
                                                    header = "High-Risk Criteria",
                                                    group_name = "bucket_list_group",
                                                    orientation = "vertical",
                                                    add_rank_list(
                                                        text = "Selected",
                                                        labels = names(variables)[c(1, 3, 6, 7)],
                                                        input_id = "selected"
                                                    ),
                                                    add_rank_list(
                                                        text = 'Not Selected',
                                                        labels = names(variables)[c(-1, -3)],
                                                        input_id = "unselected"
                                                    )
                                                ),
                                                # options for dropdownButton
                                                width = "300px",
                                                circle = FALSE, label = "Priority Criteria",
                                                tooltip = tooltipOptions(title = "Click to edit prioritization criteria")
                                            )    
                                            ),
                                     ################
                                     # hexagon plot #
                                     ################
                                     
                                     column(width = 10,
                                     plotOutput("hex_plot", hover = "plot_hover", hoverDelay = 0)))
                            )),
                
                ##############
                # data table #
                ##############
                
                fluidRow(
                    column(width = 4),
                    column(width = 8, 
                           DT::dataTableOutput("df")
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
        data <- df %>% mutate(weightRank = round(
                                                computeWeightedSum(df, variables[input$selected]), digits = 3))
        data <- hexPosition(data)
    })
    
    #############
    # hex plot #
    ############
    
    output$hex_plot <- renderPlot({

        ggplot(data = newData(), aes(x=i, y=j, fill = weightRank))+
            geom_hex(stat='identity')+
            scale_fill_gradientn(colours = ColRamp)+
            theme_bw()+
            theme(aspect.ratio = 0.5)+
            coord_flip()+
            theme(legend.position="left")+
            labs(fill='Patient Priority Score') +
            theme(axis.line=element_blank(),axis.text.x=element_blank(),
                  axis.text.y=element_blank(),axis.ticks=element_blank(),
                  axis.title.x=element_blank(),
                  axis.title.y=element_blank(),legend.position="none",
                  #panel.background=element_blank(),
                  panel.border=element_blank(),
                  panel.grid.major=element_blank(),
                  panel.grid.minor=element_blank()
                  #plot.background=element_blank() # removes borders from the app
                  )
        })
    
    
    output$df <- DT::renderDT(server=FALSE,{
        
        validate(need(input$plot_hover, "Please select a patient using your cursor"))
        
        # get MAGIQ score (rankings) for each patient
        df <- newData()
        df <- df[order(-df$weightRank), ]
        df$Priority <- 1:nrow(df)
        rownames(df) <- 1:nrow(df)
        
        # retrieve patient colours from ggplot
        g <- ggplot(data = df, aes(x=i, y=j, fill = weightRank))+
            geom_hex(stat='identity')+
            scale_fill_gradientn(colours = ColRamp)
        ggplot_data <- ggplot_build(g)$data[1][[1]]
        df$fill <- ggplot_data$fill
        
        # map weightRanks to colors used by GGplot
        color <- unique(df[c("fill", "weightRank")])
        color$fill <- paste(color$fill)
    
        # retrieve patient under cursor
        hover <- input$plot_hover # retrieve coordinates from user's cursor
        patientDF <- nearPoints(df, hover, threshold = 10) %>% 
                            select(c(Priority, 'Name', variables[input$selected]), 'weightRank')
        
        # isolate patients with adjacent weightRanks
        patient_index <- rownames(patientDF)[1] # get index of patient under selection
        patient_index_plus = (as.numeric(patient_index) + 10)
        proximal_df = df[patient_index:patient_index_plus,]
        

        # format table for plotting
        DT::datatable(data = proximal_df  %>% 
                          select(c('Name', variables[input$selected]), 'weightRank'),
                      rownames = FALSE, 
                      extensions = 'RowReorder',
                      selection = 'none',
                      autoHideNavigation = TRUE) %>%
            # add color to patient names
            formatStyle('weightRank',
                        target = 'row',
                        backgroundColor = styleInterval(cuts = rev(color$weightRank[1:length(color$weightRank)]), 
                                                        values = c(rev(color$fill), 10000)),
                        color = 'White',
                        fontWeight = 'bold')
    }) 
}

#####################
# run the shiny app #
#####################

shinyApp(ui = ui, server = server)
