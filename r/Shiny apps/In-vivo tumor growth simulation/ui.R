library(shinyIncubator)

## Model matrix:
xx <- matrix(c(c(1, 0, 0.15, 0),
               c(2, 0.5, 0.15, 0.1),
               c(3, 0.8, 0.01, 0.1)
), ncol=4, byrow=TRUE)
model_matrix <- data.frame('Treatment'=xx[, 1],'A'=xx[, 2],'g'=xx[, 3],'d'=xx[, 4])

shinyUI(pageWithSidebar(
  headerPanel('Growth-Inhibition Rate Model Simulation'),
    sidebarPanel(
      h3('Input model parameters:'),
      helpText('column 1: Treatment codes (numbers)'),
      helpText('column 2: Cell death rate'),
      helpText('column 3: Growth (g)'),
      helpText('column 4: Inhibition (d)'),
      tags$head(
        tags$style(type = "text/css"
                   , "table.data { width: 300px; }"
                   , ".well {width: 80%; background-color: NULL; border: 0px solid rgb(255, 255, 255); box-shadow: 0px 0px 0px rgb(255, 255, 255) inset;}"
                   , ".tableinput .hide {display: table-header-group; color: black; align-items: center; text-align: center; align-self: center;}"
      #             , ".tableinput-container {width: 100%; text-align: center;}"
      #             , ".tableinput-buttons {margin: 10px;}"
      #             , ".data {background-color: rgb(255,255,255);}"
                   , ".table th, .table td {text-align: center;}"
        )
      ),
      
      matrixInput('model_matrix', 'Add/Remove Treatments', data = model_matrix),
      sliderInput('TV0', '(Expected) Starting level', min=1, max=100, value=10, step=1),
      sliderInput('T', 'Follow-up length', min=1, max=30, value=20),
      sliderInput('sim', 'Treatment line sample size', min=1, max=20, value=10),
      sliderInput('var', 'Variance', min=0, max=1, value=.3, step=.01),
      checkboxInput('Censoring', label='Consider drop-outs', value=TRUE),
      tags $ hr(),
      h3('Optional'),
      checkboxInput('LOESS', label='LOESS approximation', value=FALSE),
      checkboxInput('Log10_transform', label='Log10-transform', value=FALSE),
      checkboxInput('LOCF', label='LOCF imputation', value=FALSE)
      ),

    ## Option for tabsets:
    mainPanel(
        tabsetPanel(id='Tab',
                    tabPanel('Simulation outcomes ', value=1, br(), br(),
                             downloadButton('downloadData', 'Save data (.csv)'), br(),
                             plotOutput('Simulated_levels_plot', width='90%', height='700px'), br()
                             ),
                    ##----------------------------------------------
                    tabPanel('Contact', value=2, br(),
                             h4('With questions and for help please contact the Medimmune Statistical Sciences group'), 
                             a("Email", href="mailto:kozarskir@medimmune.com")
                    )
           )
    )
  

  
  
    )) ## overall
