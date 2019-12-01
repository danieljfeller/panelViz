library(shinyjqui)
library(DT)
library(shinythemes)
library(dplyr)
library(d3heatmap)
library(ggplot2)

# convert logical vector to character
toFactor <- function(x){
  return(as.factor(ifelse(as.logical(x) == TRUE, "Yes", "No")))
}

df <- read.csv('synthetic_patients.csv') %>%
  mutate(VLS = toFactor(VLS),
         drugAbuse =toFactor(drugAbuse), 
         etohAbuse = toFactor(etohAbuse),
         LTFU = toFactor(LTFU),
         UnstableHousing = toFactor(UnstableHousing),
         MissedApt = toFactor(MissedApt),
         NewDx = toFactor(NewDx),
         HCV = toFactor(HCV),
         HTN = toFactor(HTN),
         behavioralDx = toFactor(behavioralDx),
         hospitalizationRisk = round(hospitalizationRisk, digits = 2))

################
# hex bin plot #
################

df$rank <- row_number(df$Name)
df$j <- 1
df$i <- 1

counter = 0
offset <- 0.5 #offset for the hexagons when moving up a row
for (row in 1:23){
  # change offset when increasing rows
  offset <- ifelse(offset == 0.5, 0, 0.5)
  for (column in 1:22){
    counter <- counter + 1
    df[df$rank == counter,]$i <- row
    df[df$rank == counter,]$j <- column + offset
    print(paste(counter, row, column + offset))
  }
}

# get some colors
ColRamp <- rev(designer.colors(n=10, col=brewer.pal(9, "Spectral")))

# plot the hex bins
ggplot(data = df, aes(x=i, y=j, fill=hospitalizationRisk))+
  geom_hex(stat='identity')+
  scale_fill_gradientn(colours = ColRamp)+
  theme_bw()+
  coord_flip()

ggplotly(p)


d <- ggplot(data = df, aes(x=i, y=j, z=rank))
d + stat_summary_hex(fun=sum)

###########
# heatmap #
###########

counter = 0
for (row in 1:23){
  # change offset when increasing rows
  for (column in 1:22){
    counter <- counter + 1
    df[df$rank == counter,]$i <- row
    df[df$rank == counter,]$j <- column + offset
    print(paste(counter, row, column + offset))
  }
}

ggplot(data = df, aes(x=i, y=j, fill = CD4))+
  geom_bin2d(stat='identity')+
  scale_fill_gradientn(colours = ColRamp)+
  theme_bw()

