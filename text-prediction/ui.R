#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

shinyUI(fluidPage(
    fluidRow(
        column(12, offset = 0, align="center",
            titlePanel("Auto-Completion Demo"),
            div("Coursera Data Science Capstone Project"),
            div(
                a("Github Repo", href="https://github.com/chavli/DS_Capstone"),
                "---", 
                a("Slidify Presentation", href="http://chavli.github.io/DS_Capstone/#1")
            ),
            br(),
            br()
        )
    ),
    fluidRow(
        column(3, offset = 4,
            textInput("phrase", label=NULL, value = "type here...", width = "100%", placeholder = NULL)
        ),
        column(1, offset = 0,
            actionButton("submitButton", "Predict!", icon = NULL, width = "100%",
                style="color: #fff; background-color: #337ab7; border-color: #2e6da4")
        )  
    ),
    fluidRow(
        column(4, offset = 4, align="center", textOutput("oCoreCount"), style="color: red;")
    ),
    fluidRow(
        column(4, offset = 4, align="center", h3(textOutput("oPrediction")))
    ),
    fluidRow(
        column(4, offset = 4, align="center", textOutput("oPredictionTime"))
    ),
    fluidRow(
        column(4, offset = 4, align="center", hr())
    ),
    fluidRow(
        column(4, offset = 4, align="center", plotOutput("distPlot"))
    )
))

# # Define UI for application that draws a histogram
# shinyUI(fluidPage(
#   
#   # Application title
#   titlePanel("Old Faithful Geyser Data"),
#   
#   
#   
#   # Sidebar with a slider input for number of bins 
#   sidebarLayout(
#     sidebarPanel(
#        sliderInput("bins",
#                    "Number of bins:",
#                    min = 1,
#                    max = 50,
#                    value = 30),
#        textInput("iPhrase", "type here...", value = "", width = NULL, placeholder = NULL)
#     ),
#     
#     # Show a plot of the generated distribution
#     mainPanel(
#        plotOutput("distPlot")
#     )
#   )
# ))
