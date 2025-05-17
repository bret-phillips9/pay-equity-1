# theme definition
appTheme <- bs_theme(
     version = 5,
     bootswatch = "flatly"
)

# main body contains four tabs
# 1 - an input data tab that asks the user to upload data and define columns
# 2 - an analysis tab that returns the results as a datatable
# 3 - a graph tab that provides a visualization
# 4 - a notes tab that contains technical notes for the user
appMain <- mainPanel(
     tabsetPanel(
          tabPanel("Input Data", 
                   fluidPage(
                        fluidRow(includeMarkdown("instructions.md")),
                        fluidRow(
                             column(6,
                                    fileInput(
                                       inputId = 'FileUpload',
                                       label = 'Please upload a file',
                                       multiple = FALSE,
                                       accept = c('csv', 'txt'),
                                       buttonLabel = 'Upload',
                                       placeholder = 'Waiting for a file'
                                   ),
                                  uiOutput("pay_ui"),
                                  uiOutput("lvl_ui"),
                                  uiOutput("grp_ui"),
                                  uiOutput("focal_ui")
                             ),
                             column(6,
                                    h4("Data Preview:"),
                                    uiOutput("tbl_ui")
                                    )
                        )
                   )
          ),
          tabPanel("Results Table",
                   h4("Pay Equity Analysis: t-Test Results by Pay Group"),
                   verbatimTextOutput("selection"),
                   DTOutput("ladder_ui")
          ),
          tabPanel("Results Graph",
                   h4("Pay Equity Analysis: % Disparity by Pay Group"),
                   verbatimTextOutput("selection_copy"),
                   plotOutput("graph_ui")
          ),
          tabPanel("Notes",
                   includeMarkdown("notes.md"))
     )
)

# main page code
page_navbar(
     title = "Basic Pay Equity Analyzer",
     theme = appTheme,
     appMain
)

