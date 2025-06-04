# Tracking San Francisco Smash and Grabs

(https://kpvo.shinyapps.io/sf-app/)

“Smash-and-Grabs” or “Bipping” are colloquial terms to describe the epidemic of car break-ins in the United States. According to the San Francisco Police Department, there have been already 2,137 car break-ins in the city just this year. That averages to around 14 break-ins per day. The motive for the crime is to steal valuables stored in the vehicles. Additionally, smash-and-grabs commonly occur near tourist hot-spots where many unknowing visitors frequent along with their luggage and belongings.

The data was pulled from the public city API: https://data.sfgov.org/Public-Safety/Police-Department-Incident-Reports-2018-to-Present/. The only data used was Larceny from a Vehicle in 2024. 

The shinyapp.io above serves as a centralized location for analysis and it can be useful for the public in understanding high-risk streets to park and which neighborhoods to stay extra vigilant in. Personally, in creating this app I found ways to automate EDA, point process modeling, and model evaluation. You can load this repo, change the data year and it would provide you with that year's results. You will find the simple regression model to predict neighborhood of occurrence, the top 10 neighborhoods and intersections hit and a histogram to evaluate the trend for the entire year.

The app itself uses a simple regression model to predict which neighborhood a smash-and-grab occurred using only day of the week data and month data. This simple model was created through R Plumber, Dockerized and passed to Google Cloud Run. This simple model fulfills the model api requirement of the project and its creation can be found in the larceny.R and run-api.R files.

The second, additional point process model is a Poisson model of differing degrees of polynomials. This was my personal touch and I was only able to deploy this dynamic model locally. This is due to dependency issues from the spatstat package that caused Docker to fail. Additionally, the model itself was memory heavy and after 2 models it begins to lag. When running locally on your terminal the code will save the two fitted trend and estimated se plots in your working directory. The code for this locally run model in plumber.R. To reiterate, this was just an additional model I wanted to test out for fun.
