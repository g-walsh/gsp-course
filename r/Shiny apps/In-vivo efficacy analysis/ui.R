
shinyUI(pageWithSidebar(
  headerPanel('Efficacy analysis in oncological in-vivo experiments'),
    sidebarPanel(
      h2('1) Upload data for analysis:'),
      br(),
        fileInput('data', 'Choose a CSV file from local drive:', accept=c('.csv')),
      textInput('study', label='', value=''),
      selectInput('time_unit', label = 'Choose timepoint (Tp) units:', choices = c('seconds','minutes', 'hours', 'days', 'weeks'), selected='days'),
        tags $ hr(),
      h2('2) Analysis:'),
      checkboxGroupInput('Trans', label='', choices=c('log10-transform', 'LOCF')),
      tags $ hr(),
      h4('Plots'),
      selectInput('Plot',label=NULL, choices=c('',
                                                        'Spaghetti plot',
                                                        'Median',
                                                        'Mean +/- SE',
                                                        'LOESS curves')
                  ),
      conditionalPanel(condition = "input.Plot != ''",
                       checkboxGroupInput('Tr', label='', choices=''),
                       selectInput('Day_start', label = '', choices = ''),
                       selectInput('Day_end', label = '', choices = '')
      ),
      conditionalPanel(condition = "input.Plot == 'Spaghetti plot'"),
      conditionalPanel(condition = "input.Plot == 'Median'"),
      conditionalPanel(condition = "input.Plot == 'Mean +/- SE'"),
      conditionalPanel(condition = "input.Plot == 'LOESS curves'"),
      tags $ hr(),
      h4('Statistical analysis'),
      selectInput('Test',label=NULL, choices=c('',
                                                        'Permutation-based test',
                                                        'Mixed-effect model',
                                                        'Mixed-effect model with trend')
                  ),
      conditionalPanel(condition = "input.Test == 'Permutation-based test'",
                       checkboxGroupInput('Tr_Perm', label='', choices=''),
                       selectInput('Day_start_Perm', label = '', choices = ''),
                       selectInput('Day_end_Perm', label = '', choices = '')
                  ),
      conditionalPanel(condition = "input.Test == 'Mixed-effect model'",
                       checkboxGroupInput('Tr_LME_baseline', label='', choices=''),
                       checkboxGroupInput('Tr_LME_investigated', label='', choices=''),
                       selectInput('Day_start_LME', label = '', choices = ''),
                       selectInput('Day_end_LME', label = '', choices = '')
                  ),
      conditionalPanel(condition = "input.Test == 'Mixed-effect model with trend'",
                       checkboxGroupInput('Tr_LME_trend_baseline', label='', choices=''),
                       checkboxGroupInput('Tr_LME_trend_investigated', label='', choices=''),
                       selectInput('Day_start_LME_trend', label = '', choices = ''),
                       selectInput('Day_end_LME_trend', label = '', choices = '')
                      )
    ),

    ## Option for tabsets:
    mainPanel(
        tabsetPanel(id='Tab',
                    tabPanel('Uploaded Data', value=1, br(),
                             tableOutput('raw_data')
                             ),
                    tabPanel('Plots', value=2, br(),
                           conditionalPanel(condition = "input.Plot == 'Spaghetti plot'",
                                            br(),
                                            h3('`Spaghetti` plot'),
                                            plotOutput('Spaghetti_plot', width='90%', height='800px')),
                           conditionalPanel(condition = "input.Plot == 'Median'",
                                            br(),
                                            h3('Median'),
                                            plotOutput('Median_plot', width='90%', height='800px')),
                           conditionalPanel(condition = "input.Plot == 'Mean +/- SE'",
                                            br(),
                                            h3('Mean +/- Standard Error'),
                                            plotOutput('MeanSE_plot', width='90%', height='800px')),
                           conditionalPanel(condition = "input.Plot == 'LOESS curves'",
                                            br(),
                                            h3('LOESS approximation'),
                                            plotOutput('LOESS_plot', width='90%', height='800px'))
                           ),
                    tabPanel('Statistical analysis', value=3, br(),
                           conditionalPanel(condition = "input.Test == 'Permutation-based test'",
                                            downloadButton("download_Report_Perm", "Download Report (.pdf)"),
                                            br(),br(),
                                            h4('Permutation-based test (S=1,000)'),
                                            br(),
                                            tableOutput('Permutation_test')
                                            ),
                           conditionalPanel(condition = "input.Test == 'Mixed-effect model'",
                                            downloadButton("download_Report_LME", "Download Report (.pdf)"),
                                            br(),br(),
                                            h4('Mixed-effect model summary: fixed-effects'),
                                            tableOutput('Model_LME_summary_FE'),
                                            br(),
                                            h4('Effect sizes plot:'),
                                            plotOutput('LME_effects_plot', width='70%', heigh='500px'),br(),
                                            h4('Least-squares means with effect sizes:'),
                                            tableOutput('effects_table'), br(),
                                            h4('Least-squares means plot:'),
                                            plotOutput('LME_lsmeans_plot', width='70%', heigh='1000px')
                                            ),
                             conditionalPanel(condition = "input.Test == 'Mixed-effect model with trend'",
                                              downloadButton("download_Report_LME_with_trend", "Download Report (.pdf)"),
                                              br(),br(),
                                              h4('Mixed-effect model summary: fixed-effects'),
                                              tableOutput('Model_LME_trend_summary_FE'),
                                              br(),
                                              h4('Model-derived treatment effect sizes:'),
                                              tableOutput('Model_LME_trend_GIR'), br(),
                                              h4('Fixed effect trend lines:'), 
                                              plotOutput('LME_trend_plot', width='70%', heigh='500px')                                             
                             )
                             ),
                    tabPanel('Contact', value=3, br(),
                             h4('With questions and for help please contact the Medimmune Statistical Sciences group'),
                             a("Email", href="mailto:kozarskir@medimmune.com")
                    )
           )
    )
    )) ## overall
