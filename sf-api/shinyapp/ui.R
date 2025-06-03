library(shiny)
library(bslib)
library(leaflet)

day_vars <- c("Sunday", "Monday", "Tuesday", "Wednesday","Thursday","Friday","Saturday")
month_vars <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")

navbarPage(
  title = "Predicting Neighborhood of Smash and Grab",
  theme = bs_theme(bootswatch = "flatly"),
  
  # Tab 1: Prediction Interface
  tabPanel("Neighborhood Predictor",
           sidebarLayout(
             sidebarPanel(
               width = 3,
               selectInput("day", "Day of the Week", choices = day_vars),
               selectInput("month", "Month", choices = month_vars)
             ),
             mainPanel(
               h4("The Predicted Neighborhood for your Day of the Week and Month:"),
               h3(textOutput("neighborhood"))
             )
           )
  ),
  
  # Tab 2: Full SF Map View
  tabPanel("Full SF Map View",
           h5("Warning: This may take a moment to load."),
           h5("Locations of San Francisco Smash and Grabs in 2024"),
           leafletOutput("map", height = 600)
  ),
  # Tab 3: Neighborhood Trends
  tabPanel("Neighborhood and Intersection Overview",
           fluidRow(
             column(6,
                    h4("Top 10 Neighborhoods Hit"),
                    tableOutput("top_neighborhoods")
             ),
             column(6,
                    h4("Top 10 Intersections Hit"),
                    tableOutput("top_intersections")
             )
           )
  ),
  # Tab 4: Histogram
  tabPanel("2024 Smash and Grab Trend",
           fluidRow(
             column(12,
                    h4("Histogram of Incidents by Month"),
                    plotOutput("histogram")
             )
           )
  )
  
)
