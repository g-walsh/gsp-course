
shinyUI(pageWithSidebar(
    headerPanel('Design of oncological in-vivo experiments'),
    sidebarPanel(
      h4('Effect size measure'),
      selectInput('ES',label=NULL, choices=c('',
                                             'Cohen`s d',
                                             'Growth Inhibition Rate')
                  ),
      conditionalPanel(condition = "input.ES == 'Cohen`s d'", br(),
                      h4(em(strong('Effect size magnitudes:'), br(), 
                      strong('- small: 0.2'),br(),
                      strong('- medium: 0.5'),br(), 
                      strong('- large: 0.8'))),
                       br(),br(),
                       numericInput('ES_d_point', 'Expected d:',  0.5, min=0, max=5, step=.01),
                       numericInput('ES_d_min','- min expected d:', .2, min=0, max='', step=.01),
                       numericInput('ES_d_max','- max expected d:', .8, min=0, max='', step=.1),
                       actionButton("run_d", "Submitt")
                       ),
      conditionalPanel(condition = "input.ES == 'Growth Inhibition Rate'", br(),
                       h4(em(strong('Effect size magnitudes:'), br(), 
                          strong('- small: 5%'),br(),
                          strong('- medium: 20%'),br(), 
                          strong('- large: 40% and more'))),
                       br(),br(),
                       numericInput('ES_GIR_point','Expected % Growth Inhibition Rate (GIR):',  20, min=0, max='', step=5),
                       numericInput('ES_GIR_min','- min expected GIR(%):', 5, min=0, max='', step=5),
                       numericInput('ES_GIR_max','- max expected GIR(%):', 40, min=0, max='', step=5),
                       numericInput('Timepoints','Follow-up length (days):', 10, min=1, max='', step=1),
                       numericInput('n','Target sample size:', 10, min=1, max='', step=1),
                       actionButton("run_GIR", "Submitt")
      ),

      tags $ hr(),
      radioButtons('alpha', label='Select significance (Type I error) level(s):', choices=c(0.05, 0.1), selected=0.05),
      hr(),
      textInput("study", 'Study name:', value='')
      ),

    ## Option for tabsets:
    mainPanel(
        tabsetPanel(id='Tab',
                    tabPanel('Study design', value=1, br(),
                           conditionalPanel(condition = "input.ES == 'Cohen`s d'",                           
                                            br(),
                                            downloadButton("download_report_ES_d", "Study design report (.pdf)"),
                                            br(),br(),
                                            plotOutput('powerCurve_ES_d', width='70%', height='600px')
                                            ),
                             conditionalPanel(condition = "input.ES == 'Growth Inhibition Rate'",                           
                                              br(),br(),
                                              plotOutput('powerCurve_ES_GIR', width='70%', height='600px')
                             )),
                    tabPanel('Contact', value=2, br(),
                             h4('With questions and for help please contact the MedImmune Statistical Sciences  group'),
                             a("Email", href="mailto:kozarskir@medimmune.com")
                    )  
                    
                    )
        )
    )) ## overall
