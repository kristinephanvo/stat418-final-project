# main.R
library(plumber)
pr <- pr("larceny.R")
pr$run(host = "0.0.0.0", port = 8000)
