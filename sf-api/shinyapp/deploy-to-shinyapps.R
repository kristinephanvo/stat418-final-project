
#deploy to shinyapps.io
#first you will need an account

#install.packages('rsconnect')

#name is account name, get both your authentication token and secret in your account
rsconnect::setAccountInfo(name='kpvo',
              token='****',
              secret='****')

setwd("~/sf-api/shinyapp")
library(rsconnect)
rsconnect::deployApp(appName="sf-app")

#this is now running at
#https://kpvo.shinyapps.io/sf-app/
