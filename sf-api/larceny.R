# plumber.R
library(plumber)
library(nnet)    # for multinom()
library(readr)
library(dplyr)

# Load and prepare data
larceny_df <- read_csv("larceny_df_2024.csv") %>%
  mutate(
    analysis_neighborhood = as.factor(analysis_neighborhood),
    incident_day_of_week = as.factor(incident_day_of_week),
    incident_month_rx = as.factor(incident_month_rx)
  )

# Fit multinomial logistic regression model
model <- multinom(analysis_neighborhood ~ incident_day_of_week + incident_month_rx, data = larceny_df)

#* Predict neighborhood from day and month
#* @param day Day of the week (e.g., "Monday")
#* @param month Incident month (e.g., "January")
#* @get /predict_neighborhood
function(day, month) {
  # Prepare input
  input <- data.frame(
    incident_day_of_week = factor(day, levels = levels(larceny_df$incident_day_of_week)),
    incident_month_rx = factor(month, levels = levels(larceny_df$incident_month_rx))
  )
  
  # Predict neighborhood
  pred <- predict(model, newdata = input)
  
  list(
    input = input,
    predicted_neighborhood = pred
  )
}
