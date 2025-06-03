library(httr)
library(jsonlite)
library(leaflet)
library(mapview)
library(readr)
library(dplyr)
library(ggplot2)

# Load data once
larceny_df <- read_csv("larceny_df_2024.csv")

function(input, output, session) {
  
  # Prediction text output
  output$neighborhood <- renderText({
    day <- input$day
    month <- input$month
    
    response <- GET(
      url = "https://larceny-api-253216833082.us-central1.run.app/predict_neighborhood",
      query = list(day = day, month = month)
    )
    
    if (response$status_code != 200) {
      return("Error: API request failed.")
    }
    
    data <- fromJSON(rawToChar(response$content))
    paste("Predicted Neighborhood:", data$predicted_neighborhood)
  })
  
  # Map output
  output$map <- renderLeaflet({
    leaflet(larceny_df) %>%
      addTiles() %>%
      addCircleMarkers(~longitude, ~latitude, radius = 2, fillOpacity = 0.7)
  })
  
  # Top 10 neighborhoods
  output$top_neighborhoods <- renderTable({
    larceny_df %>%
      count(analysis_neighborhood, sort = TRUE) %>%
      head(10)
  })
  
  # Top 10 intersections
  output$top_intersections <- renderTable({
    larceny_df %>%
      count(intersection, sort = TRUE) %>%
      head(10)
  })
  
  # Histogram plot (safe version bc of my model tab)
  output$histogram <- renderPlot({
    
    # Local copy with month factorized just for plotting
    plot_df <- larceny_df %>%
      mutate(incident_month_rx = factor(incident_month_rx, levels = month.abb))
    
    ggplot(plot_df, aes(x = incident_month_rx)) +
      geom_histogram(stat = "count", fill = "lightblue", color = "black", alpha = 0.6) +
      geom_freqpoly(stat = "count", color = "red", size = 1) +
      labs(title = "2024 Smash and Grabs by Month",
           x = "Month",
           y = "Frequency") +
      theme_minimal() +
      theme(plot.title = element_text(hjust = 0.5))
  })
  
  
}
