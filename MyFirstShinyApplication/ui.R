#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(lgrdata)
library(ggplot2)
library(RColorBrewer)

shinyUI(fluidPage(
    titlePanel("Visualize Many Models"),
    sidebarLayout(
        sidebarPanel(
            checkboxInput("footLength", "Add foot length as predictor", value = TRUE),
            checkboxInput("ageInput", "Add age as predictor", value = TRUE),
            checkboxInput("genderInput", "Add gender as predictor", value = TRUE),
            radioButtons("modelInput", "Model:",
                         c("Random Forest" = "rf",
                           "Generalized Linear Model" = "glm",
                           "Boosting" = "gbm"), selected = "glm"),
            submitButton("Submit") # New!
            
        ),
        mainPanel(
            tabsetPanel(type = "tabs", 
                        tabPanel("Prediction", br(), plotOutput("plotModel")), 
                        tabPanel("Data summary", plotOutput("plot1", brush = brushOpts(
                            id = "brush1"
                        )),
                        plotOutput("plot2"),
                        plotOutput("plot3")
                        ), 
                        tabPanel("Documentation", br(), textOutput("out3"))
            )
        )
    )
))
