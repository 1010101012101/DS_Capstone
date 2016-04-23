#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#
setwd("~/Coursera/capstone-code/") # remove when deploying

library(shiny)
library(ggplot2)
library(dplyr)
library(RColorBrewer)
source("kats-backoff.R")

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  predict <- eventReactive(input$submitButton, {
      start_t <- Sys.time()
      predictions <- data.frame(words=c("scotch", "world", "goodbye", "cha"), probs=c(.4, .3, .1, .2 ))
      predictions <- transform(predictions, words = reorder(words, probs))
      delta_t <- Sys.time() - start_t
      list("predictions"=predictions, "time"=delta_t)
  })
    
  output$oPrediction <- renderText({
      results = predict()
      topword <- results$predictions[1, "words"]
      paste("Predicted Next Word:", topword)
  })
  
  output$oPredictionTime <- renderText({
      results = predict()
      paste("Prediction Time:", results$time)
  })    
  
  output$distPlot <- renderPlot({
    results <- predict() %>% head(10)

    ggplot() +
        geom_bar(data=results$predictions, aes(x=words, y=probs, fill=words), stat="identity") +
        coord_flip() + 
        scale_fill_brewer() +
        ggtitle("Top 10 Most Likely Words") +
        labs(x="", y = "Probability") +
        guides(fill=F)
  })
  
})
