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

    # Application title
    titlePanel("Old Faithful Geyser Data"),

    # Sidebar with a slider input for number of bins 
    fluidRow(
            sliderInput("bins",
                        "Number of bins:",
                        min = 1950,
                        max = 2018,
                        value = c(1990, 2018)
            )),

        # Show a plot of the generated distribution
        fluidRow(
           plotOutput("distPlot")
        )
    )

# Define server logic required to draw a histogram
server <- function(input, output) {

    output$distPlot <- renderPlot({
       
        # read ratlas data
        obs <- dplyr::left_join(ratlas::get_timeseries(), 
                                ratlas::get_gen(endpoint="taxa"), 
                                by = c("id_taxa" = "id"))
        
        # split into list per series to calculate log-ratio index for each population
        obs <- dplyr::group_split(obs, by = as.factor(id)) %>%
            lapply(tableaulpi::lpi_population) %>%
            dplyr::bind_rows() # rebind together
        obs$mean_dt[is.infinite(obs$mean_dt)] <- NA
        
        # remove first entry of each time series 
        # (the first dt is set to 0 and first lpi is set to 1 automatically, so is uninformative)
        obs$years <- lapply(obs$years, function(x) x <- x[-1])
        obs$dt <- lapply(obs$dt, function(x) x <- x[-1])
        obs$lpi <- lapply(obs$lpi, function(x) x <- x[-1])
        
        # break dataset into 1 row per year and lpi value
        obs <- tidyr::unnest(obs, cols = c(dt, years, lpi))
        
        # filter year of choice
        obs <- dplyr::filter(obs, years >= input$bins[1] & years <= input$bins[2])

        # draw the histogram with the specified number of bins
        
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
