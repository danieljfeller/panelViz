# panelViz
Related to research on visual analytics in healthcare

### 1st tab w/ criteria selection & panel visualization
#### add/remove criteria
https://github.com/rstudio/shiny-examples/tree/master/036-custom-input-control
chooser.R contains reusable R function chooserInput that can be used in ui.R. It also registers an input handler with Shiny to reshape the data into a nicer form before handing it over to the app's server side R code.

### select & order criteria
updateSelectizeInput()

### histogram of distribution?
### scatterplot of priority score?  (enables exploration on patient-level)
https://plot.ly/ggplot2/geom_jitter/


### 2nd tab w/  tabular representation (action)
#### DataTable Options
 - show X entries
 - search by name

### HTML widgets for tabular data
Formattable: https://renkun-ken.github.io/formattable/
DT: https://rstudio.github.io/DT/
- buttons: https://datatables.net/extensions/buttons/custom
LineUp: https://github.com/datavisyn/lineup_htmlwidget

### Customized Buttons
 - Upweight | Downweight
 https://antoineguillot.wordpress.com/2017/03/01/three-r-shiny-tricks-to-make-your-shiny-app-shines-33-buttons-to-delete-edit-and-compare-datatable-rows/

### color cells or rows
 - https://rstudio.github.io/DT/010-style.html
