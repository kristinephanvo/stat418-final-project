# plumber.R

library(plumber)
library(dplyr)
library(spatstat)
library(splancs)

#* Fit Poisson model and return fitted trend and SE plot
#* @param degree Polynomial degree for trend surface
#* @get /fit_model
#* @serializer contentType list(type="image/png")
function(degree = 3) {
  degree <- as.integer(degree)
  
  # Load and filter data
  larceny_2024 <- read.csv("larceny_df_2024.csv")
  
  lon_raw <- larceny_2024$longitude
  lat_raw <- larceny_2024$latitude
  
  # Standardize coordinates
  z <- list()
  z$lon <- (lon_raw - min(lon_raw)) / (max(lon_raw) - min(lon_raw))
  z$lat <- (lat_raw - min(lat_raw)) / (max(lat_raw) - min(lat_raw))
  
  x1 <- z$lon + rnorm(length(z$lon), mean = 0, sd = 0.00001) 
  y1 <- z$lat + rnorm(length(z$lat), mean = 0, sd = 0.00001)
  
  d1 <- as.matrix(dist(cbind(x1, y1)))
  n1 <- length(x1)
  
  # Fit Poisson model with polynomial intensity
  b1 <- as.points(x1, y1)
  b2 <- as.ppp(b1, W = c(0, 1, 0, 1)) 
  form <- as.formula(paste("~ polynom(x, y,", degree, ")"))
  fit <- ppm(b2, form, Poisson())
  
  # Save plots to temp file
  tmp <- tempfile(fileext = ".png")
  png(tmp, width = 1200, height = 600)
  par(mfrow = c(1, 2))
  
  # Let plot.ppm() handle layout and draw both plots correctly
  plot(fit, which = c("trend", "se"))
  
  dev.off()
  
  
  # Return the image
  readBin(tmp, "raw", n = file.info(tmp)$size)
}
