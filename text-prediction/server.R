#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(ggplot2)
library(dplyr)
library(RColorBrewer)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
   
  output$oPrediction <- renderText({
      "Most Likely Word: hello"
  })
  
  output$oPredictionTime <- renderText({
      "Prediction Time: .5 seconds"
  })    
  
  output$distPlot <- renderPlot({
    
    # dummy df representing probability of next word
    df <- data.frame(words=c("hello", "world", "goodbye", "cha"), probs=c(.4, .3, .1, .2 ))
    df <- transform(df, words = reorder(words, probs))
    
    ggplot() +
        geom_bar(data=df, aes(x=words, y=probs, fill=words), stat="identity") +
        coord_flip() + 
        scale_fill_brewer() +
        ggtitle("Top 10 Most Likely Words") +
        labs(x="", y = "Probability") +
        guides(fill=F)
      
  })
  
})
