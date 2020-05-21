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
    titlePanel("Predict Child Height"),
    verticalLayout(
        div(
            p(
                "This app uses the anthropometry dataset provided by package 'lgrdata'. This data include measurements of age, foot length, gender, and height for 3898 children."
            ),
            p("Navigate through the tabs bellow.")
        ),
        tabsetPanel(
            type = "tabs",
            tabPanel(
                "Data summary",
                div(p(" ")),
                p(
                    "Bellow you can have an overall understanding of the data. The first plot shows the height by age of the childs. The second plot show the height by foot length of the childs. The third plot shows a boxplot of height by gender of the childs."
                ),
                verbatimTextOutput("dataSummaryOut"),
                plotOutput("plot1"),
                plotOutput("plot2"),
                plotOutput("plot3")
            ),
            tabPanel(
                "Prediction",
                div(p(" ")),
                p(
                    "Now you can choose a method and predictors to build a model on the data. Then you can provide some values for the predictors and see the height prediction."
                ),
                p("Be aware that the model training can take some time to finish."),
                sidebarLayout(
                    sidebarPanel(
                        h3("Parameters"),
                        p(),
                        checkboxInput("addFootLength", "Add foot length as predictor", value = TRUE),
                        checkboxInput("addAge", "Add age as predictor", value = TRUE),
                        checkboxInput("addGender", "Add gender as predictor", value = TRUE),
                        radioButtons(
                            "modelInput",
                            "Model:",
                            c(
                                "Generalized Linear Model" = "glm",
                                "Random Forest" = "rf"
                            ),
                            selected = "glm"
                        ),
                        actionButton("buildModelButton", "Build Model")
                    ),
                    mainPanel(verticalLayout(
                        h2("Prediction"),
                        inputPanel(
                            numericInput(
                                "ageValue",
                                "Age (in years)",
                                value = 5,
                                min = 0.5,
                                max = 20,
                                step = 0.5
                            ),
                            numericInput(
                                "footLengthValue",
                                "Foot Length (in mm)",
                                value = 130,
                                min = 100,
                                max = 350,
                                step = 1
                            ),
                            selectInput("genderValue", "Gender", c("male", "female")),
                            actionButton("predictButton", "Predict")
                        ),
                        div(p(verbatimTextOutput("textPrediction")),),
                        h2("Generated Model"),
                        div(
                            p(verbatimTextOutput("modelOutput")),
                            p(verbatimTextOutput("rmseOnTraining")),
                            p(verbatimTextOutput("rmseOnTesting"))
                        ),
                        plotOutput("plotModel")
                    ))
                    
                )
            ),
            tabPanel(
                "Height and Foot Length LM",
                div(p(" ")),
                p("Here you can select points to visualize a linear model."),
                br(),
                div(
                    p("Slope: ", verbatimTextOutput("slopeOut")),
                    p("Intercept: ", verbatimTextOutput("interceptOut")),
                ),
                plotOutput("plotHeightFootLength", brush = brushOpts(id = "brushHeightFootLength"))
            ),
            tabPanel(
                "Documentation",
                div(p(" ")),
                h2("Predict Child Height from Foot length, Age and/or Gender"),
                p("This is a simple application developed to explore the concepts of Shiny Applications.
                  The mains goal of this application is to allow users to build models for prediction of child height based on a subset
                  of three predictors: age, foot length and gender"),
                p("The user interface has four tabs. Next I will explain the first three, as you are noew reading the fourth tab (Documentation)"),
                h3("Data summary"),
                p("The first tab shows a quick summary of the data set used by this application, with no interactivity. It has a summary of the dataset and three plots."),
                p("The first plot shows the childs height by age, with different colors for male and female.
                  The second plot show the childs height by foot length, also with different colors to identify male and female.
                  The third plot shows a boxplot of childs height by gender."),
                h3("Predict"),
                p("The second tab shows an interactive interface so users can build a model to predict a child height based on the selected predictors."),
                p("The interface has three main areas. On the left you should specify the parameters for buildin the model.
                  You must select which predictors should be used, and the method that will be used to fit the model. There are two available methods, Linear Model and Random Forest."),
                p("After selecting the method and the predictors, you should click on 'Build Model'."),
                p(strong("The model fitting can take time, specially the random forest method.")),
                p("To reduce the ammount of time needed to build the model, both models are using the same trainControl, cross-validation with only 3 folds."),
                p("In order to build the model and check its quality, the dataset is randomly partitioned in training and testing datasets, with 80% and 20% of all available samples."),
                p(code("trainControl(method = 'cv', savePredictions = 'none', number = 3)")),
                p("After building the model, the summary of the final model will be shown bellow the title 'Generated model'.
                  Just bellow the summary it will be presented the Root-Mean-Square Error for training and testing (the expected out-of-sample RMSE)."),
                p("Since the model is built, you can generate predictions of childs height. You just need to input the same predictors selected to build the model, leaving the others blank, and click on 'Predict' button."),
                p("The predicted height will be shown just bellow the predictors input panel."),
                h3("Height and Foot Length LM"),
                p("The third tab was created after I identified that the best individual predictor, i. e. the one with the highest correlation
                  is foot length. So I decided to build an interactive plot where the user can select a set of points and the application will draw 
                  a line representing the linear model fit with the selected points."),
                p("In this tab you just need to select points and the apllication will draw the green line representing the linear model and show its slope and intercept."),
                h3("Source code"),
                p("if you are interested, the sourcecode of this apllication is available on ", a(href="https://github.com/ricardorac/ddp_final/tree/master/MyFirstShinyApplication","github"),"."),
            )
        )
    )
))
