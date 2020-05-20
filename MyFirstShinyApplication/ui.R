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

shinyUI(
    fluidPage(
    titlePanel("Predict Child Height"),
    verticalLayout(
        div(
            p("This app uses the anthropometry dataset provided by package 'lgrdata'. This data include measurements of age, foot length, and height for 3898 children."),
            p("Navigate through the tabs bellow.")
            ),
        tabsetPanel(type = "tabs", 
                        tabPanel("Data summary",
                                 div(p(" ")),    
                                 p("Bellow you can have an overall understanding of the data. The first plot shows the height by age of the childs. The second plot show the height by foot length of the childs. The third plot shows a boxplot of height by gender of the childs."),
                                 plotOutput("plot1"),
                                 plotOutput("plot2"),
                                 plotOutput("plot3")
                                 ), 
                        tabPanel("Prediction", 
                                 div(p(" ")),    
                                 p("Now you can choose a method and predictors to build a model on the data. Then you can provide some values for the predictors and see the height prediction."),
                                 p("Be aware that the model training can take some time to finish."),
                                 sidebarLayout(
                                     sidebarPanel(
                                         checkboxInput("addFootLength", "Add foot length as predictor", value = TRUE),
                                         checkboxInput("addAge", "Add age as predictor", value = TRUE),
                                         checkboxInput("addGender", "Add gender as predictor", value = TRUE),
                                         radioButtons("modelInput", "Model:",
                                                      c("Generalized Linear Model" = "glm",
                                                        "Random Forest" = "rf"),
                                                      selected = "glm"),
                                         actionButton("buildModelButton", "Build Model"),
                                     ),
                                     mainPanel(
                                         verticalLayout(
                                             inputPanel(
                                                 textInput("ageValue", "Age"),
                                                 textInput("footLengthValue", "Foot Length"),
                                                 textInput("genderValue", "Gender"),
                                                 actionButton("predictButton", "Predict")
                                             ),
                                             textOutput("textPrediction"),
                                             plotOutput("plotModel")
                                         )
                                     )
                                     
                                 )
                             ), 
                        tabPanel("Documentation",
                                 div(p(" ")),    
                                 p("Here you can access a more detailed explanation on how to use this Shiny Application."),
                                 br()
                                 )
            )
        )
    )
)
