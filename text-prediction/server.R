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
    load("models/comp_katzmodel_500_2.cha")
    
    output$oCoreCount <- renderText({
        ncores = max(parallel::detectCores() - 1, 1)
        paste("Available CPU Cores:", ncores)
    })
    
    predict <- eventReactive(input$submitButton, {
        phrase = input$phrase
        
        start_t = Sys.time()
        predictions = parallel_nextwords(comp_katzmodel_500_2, string = phrase,
                                         cores = max(parallel::detectCores() - 1, 1))
        predictions = predictions %>% 
            mutate(word=trimws(word)) %>% 
            group_by(word) %>% 
            summarise(p=max(p)) %>% 
            arrange(desc(p)) %>% head(10)
        
        predictions = transform(predictions, word = reorder(word, p))
        delta_t = Sys.time() - start_t
        list("predictions"=predictions, "time"=delta_t)
    })
    
    output$oPrediction <- renderText({
        results = predict()
        
        if(results$predictions[1, "p"] == -1){
            paste("No predictions for:", input$phrase)
        } else{
            topword = results$predictions[1, "word"]
            paste("Predicted Next Word:", topword)            
        }
    })
    
    output$oPredictionTime <- renderText({
        results = predict()
        paste("Prediction Time:", round(results$time, 4), "seconds")
    })
    
    output$distPlot <- renderPlot({
        results = predict()
        if(results$predictions[1, "p"] >= 0){
            ggplot() +
                geom_bar(data=results$predictions, aes(x=word, y=p, fill=word), stat="identity") +
                coord_flip() +
                scale_fill_manual(values=colorRampPalette(c("#00d2ff", "#3a7bd5"))(10)) +
                ggtitle("Top 10 Most Likely Words") +
                labs(x="", y = "Probability") +
                guides(fill=F)
        }
    })
    
})
