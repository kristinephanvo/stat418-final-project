
#deploy to shinyapps.io
#first you will need an account

#install.packages('rsconnect')

#name is account name, get both your authentication token and secret in your account
rsconnect::setAccountInfo(name='kpvo',
              token='5BC2CFF06242E2B7D00C57CFB71C6D85',
              secret='fE+YH9J+kMls9rgtFaHY748/5KRHTIDzrAn67Xu1')

setwd("~/sf-api/shinyapp")
library(rsconnect)
rsconnect::deployApp(appName="sf-app")

#this is now running at
#https://kpvo.shinyapps.io/sf-app/
