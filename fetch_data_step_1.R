
### BEGIN FETCHING DATA FROM API ###
library(httr)
library(jsonlite)
library(dplyr)
library(tidyverse)
library(ggplot2)
library(mapview)

# Base API endpoint vs query in the enpoint link
# Original API endpoint with query https://data.sfgov.org/resource/wg3w-h783.json?$query=SELECT%0A%20%20%60incident_datetime%60%2C%0A%20%20%60incident_date%60%2C%0A%20%20%60incident_time%60%2C%0A%20%20%60incident_year%60%2C%0A%20%20%60incident_day_of_week%60%2C%0A%20%20%60report_datetime%60%2C%0A%20%20%60row_id%60%2C%0A%20%20%60incident_id%60%2C%0A%20%20%60incident_number%60%2C%0A%20%20%60cad_number%60%2C%0A%20%20%60report_type_code%60%2C%0A%20%20%60report_type_description%60%2C%0A%20%20%60filed_online%60%2C%0A%20%20%60incident_code%60%2C%0A%20%20%60incident_category%60%2C%0A%20%20%60incident_subcategory%60%2C%0A%20%20%60incident_description%60%2C%0A%20%20%60resolution%60%2C%0A%20%20%60intersection%60%2C%0A%20%20%60cnn%60%2C%0A%20%20%60police_district%60%2C%0A%20%20%60analysis_neighborhood%60%2C%0A%20%20%60supervisor_district%60%2C%0A%20%20%60supervisor_district_2012%60%2C%0A%20%20%60latitude%60%2C%0A%20%20%60longitude%60%2C%0A%20%20%60point%60%0AWHERE%0A%20%20caseless_eq(%60incident_year%60%2C%20%222024%22)%0A%20%20AND%20caseless_eq(%60incident_subcategory%60%2C%20%22Larceny%20-%20From%20Vehicle%22)
# Original API endpoint was created by the website but it had a few issues:

# Was very long and I realize it was not helpful if I wanted to recreate this on my own
# Querying is super helpful and I wanted to keep this quality of the API endpoint

# The API has a default limit of providing 1,000 rows
# I needed to incorporate a off set and limit parameter but this wasn't enough

# Two issues emerged 
# First, I could not add $limit=XX&$offset=XX to the end of the API query endpoint
# Looking online I learned that I need to include it into the query 

# Secondly,  I began with a limit parameter, but that wasn't enough
# The maximum limit I was able to fetch was 100000
# According to the API documentation I needed to incorporate a offset parameter
# The offset parameter allows me to begin fetching new rows beginning from where the limit stopped previously
# The example is here https://support.socrata.com/hc/en-us/articles/202949268-How-to-query-more-than-1000-rows-of-a-dataset

# I learned this was called "paging" through data

# Function to page through data, while 
build_query_url <- function(limit, offset) {
  base <- "https://data.sfgov.org/resource/wg3w-h783.json?$query="
  sql <- sprintf(
    "SELECT
      incident_datetime,
      incident_date,
      incident_time,
      incident_year,
      incident_day_of_week,
      report_datetime,
      row_id,
      incident_id,
      incident_number,
      cad_number,
      report_type_code,
      report_type_description,
      filed_online,
      incident_code,
      incident_category,
      incident_subcategory,
      incident_description,
      resolution,
      intersection,
      cnn,
      police_district,
      analysis_neighborhood,
      supervisor_district,
      supervisor_district_2012,
      latitude,
      longitude,
      point
    WHERE caseless_eq(incident_subcategory, 'Larceny - From Vehicle')
    LIMIT %d OFFSET %d", limit, offset
  )
  paste0(base, URLencode(sql))
}

# Initialize values
limit <- 50000
offset <- 0
page <- 1
all_data <- list()

repeat {
  cat("Fetching page", page)
  
  url <- build_query_url(limit, offset)
  response <- GET(url)
  page_data <- fromJSON(content(response, as = "text"))
  
  if (length(page_data) == 0) break  # Stop if no more rows
  
  all_data[[page]] <- page_data
  
  # Next loop's arguments
  offset <- offset + limit
  page <- page + 1
}

# Combine all pages into one data frame
larceny_df <- bind_rows(all_data)

### END OF FETCHING DATA FROM API ###

#####################################
####################################
####################################

### BEGIN DATA CLEANING ###

# Use domain knowledge of the area
# Reg expression to extract month

# Cleaning the incident_datetime variable
larceny_df$incident_datetime_parsed <- ymd_hms(larceny_df$incident_datetime)

larceny_df$incident_year_rx <- year(larceny_df$incident_datetime_parsed)
larceny_df$incident_month_rx <- month(larceny_df$incident_datetime_parsed, label = TRUE, abbr = TRUE)
larceny_df$incident_year_month_rx <- format(larceny_df$incident_datetime_parsed, "%Y-%b")

# I need below to help order my factor levels
larceny_df$incident_year_month_date_rx <- as.Date(paste0(larceny_df$incident_year_month_rx, "-01"), format = "%Y-%b-%d")

# Turn into factors with the correct levels
larceny_df$incident_year_month_rx <- factor(
  larceny_df$incident_year_month_rx,
  levels = unique(larceny_df$incident_year_month_rx[order(larceny_df$incident_year_month_date_rx)])
)

# clean longitude and latitude data 

larceny_df$latitude <- as.numeric(larceny_df$latitude)
larceny_df$longitude <- as.numeric(larceny_df$longitude)

# Remove rows with NA lat/lon
larceny_df <- larceny_df[!is.na(larceny_df$longitude) & !is.na(larceny_df$latitude), ]

#larceny_2024 <- larceny_df %>% 
#  filter(incident_year == 2024)

#larceny_df_spatial_24 <- na.omit(larceny_2024[, c("latitude", "longitude")])


# Histogram
#larceny_2024$incident_month <- factor(larceny_2024$incident_month, levels = month.abb)

# Plot
#ggplot(larceny_2024, aes(x = incident_month)) +
#  geom_bar(fill = "lightblue", color = "black", alpha = 0.5) +
#  geom_line(stat = "count", aes(group = 1), color = "red", size = 1) +
#  labs(title = "Histogram of 2024 Smash-and-Grab Incidents by Month",
#       x = "Month",
#       y = "Frequency") +
#  theme_minimal() +
#  theme(plot.title = element_text(hjust = 0.5))


# Mapview
# mapview(larceny_df_spatial_24, xcol = "longitude", ycol = "latitude", crs = 4269, grid = FALSE)
 

table(larceny_df$incident_year)


# Then write to CSV

#remove point and coord columns
larceny_clean <- larceny_df[, -c(26, 27)]

write_csv(larceny_clean, "larceny_df.csv")

larceny_df <- read_csv("larceny_df.csv", show_col_types = FALSE)

read.csv("larceny_df.csv")

larceny_df_2024 <- raw_data %>% 
  filter(incident_year == 2024)

write_csv(larceny_df_2024, "larceny_df_2024.csv")

larceny_df_2025 <- raw_data %>% 
  filter(incident_year == 2025)

write_csv(larceny_df_2025, "larceny_df_2025.csv")

# Top 10 Intersections
top_intersections <- larceny_2024 %>%
  count(intersection, sort = TRUE) %>%
  top_n(10, n)

print("Top 10 Intersections:")
print(top_intersections)

# Top 10 analysis-neighborhoo (rename to make it easier if needed)
top_neighborhoods <- larceny_2024 %>%
  count(`analysis_neighborhood`, sort = TRUE) %>%
  top_n(10, n)

print("Top 10 Analysis Neighborhoods:")
print(top_neighborhoods)

write_xlsx(
  list(
    Top_Intersections = top_intersections,
    Top_Neighborhoods = top_neighborhoods
  ),
  path = "top_10_larceny_stats.xlsx"
)