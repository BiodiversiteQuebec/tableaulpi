#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
ui <- fluidPage(
    fluidRow(
        shinyWidgets::sliderTextInput("target_years",
                                      label = NULL,
                                      choices = as.character(c(1950:2018)),
                                      selected = c("1990","2018"))
        ),
    hr(),
    fluidRow(verbatimTextOutput("range"))
    
)

# Define server logic required to draw a histogram
server <- function(input, output) {

    reactive({input$slider2})
    
    output$range <- renderPrint({ as.integer(input$target_years) })
}

# Run the application 
shinyApp(ui = ui, server = server)
