# reference
# http://ramnathv.github.io/slidify/start.html
setwd("/home/cha/Coursera/capstone-slidify/")
library(slidify)
library(slidifyLibraries)
slidify("index.Rmd")
publish(user="chavli", repo="DS_Capstone", host="github")