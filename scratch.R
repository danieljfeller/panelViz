


getCD4column <- 'CD4' %in% c('VLS', 'CD4')
c('CD4')[getCD4column]

getCOSTcolumn <- 'Cost' %in% c('VLS', 'CD4')
c('Cost')[getCOSTcolumn]


%>%
  # add colors to continuous variables
  formatStyle('CD4', 
              backgroundColor = styleInterval(cd4_brks, gradientColors)) %>%
  formatStyle('hospitalizationRisk', 
              backgroundColor = styleInterval(hosp_risk_brks, gradientColors)) %>%
  formatStyle('Cost', 
              backgroundColor = styleInterval(cost_brks, gradientColors)) %>%
  formatStyle('HbA1c', 
              backgroundColor = styleInterval(hba1c_brks, gradientColors)) 

