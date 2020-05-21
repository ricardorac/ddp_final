#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(lgrdata)
library(ggplot2)
library(RColorBrewer)
library(caret)

data(anthropometry)
set.seed(1979)

anthropometry <- anthropometry[complete.cases(anthropometry), ]
inTrain = createDataPartition(anthropometry$height, p = 0.8)[[1]]
testing = anthropometry[-inTrain, ]
training = anthropometry[inTrain, ]

trainCtrl <-
    trainControl(method = "cv",
                 savePredictions = "none",
                 number = 3)

RMSE <- function(m, o) {
    sqrt(mean((m - o) ^ 2))
}

pal <- "Set1"

shinyServer(function(input, output) {
    formula <- ""
    
    model <- reactive({
        if (input$buildModelButton) {
            selMethod <- input$modelInput
            
            selPred <- c()
            if (input$addFootLength) {
                selPred <- c(selPred, "foot_length")
            }
            if (input$addAge) {
                selPred <- c(selPred, "age")
            }
            if (input$addGender) {
                selPred <- c(selPred, "gender")
            }
            
            if (length(selPred) == 0) {
                return(NULL)
            }
            selFormula <-
                as.formula(paste("height", paste(selPred, collapse = " + "), sep = " ~ "))
            modFit <-
                train(
                    selFormula,
                    method = selMethod,
                    data = training,
                    trControl = trainCtrl,
                    model = FALSE
                )
            
            modFit
        } else {
            return(NULL)
        }
    })
    modelFootLength <- reactive({
        brushed_data <-
            brushedPoints(
                anthropometry,
                input$brushHeightFootLength,
                xvar = "foot_length",
                yvar = "height"
            )
        if (nrow(brushed_data) < 2) {
            return(NULL)
        }
        lm(height ~ foot_length, data = brushed_data)
    })
    output$dataSummaryOut <- renderPrint(
        summary(anthropometry)
    )
    output$rmseOnTesting <-  reactive({
        if (input$buildModelButton) {
            modFit <- model()
            if (is.null(modFit)) {
                return("You have to build a model first.")
            } else {
                pred <- predict(modFit, testing)
                return(paste(
                    "RMSE on testing samples: ",
                    RMSE(pred, testing$height),
                    " (expected out-of-sample RMSE)"
                ))
            }
        }
    })
    output$rmseOnTraining <-  reactive({
        if (input$buildModelButton) {
            modFit <- model()
            if (is.null(modFit)) {
                return("You have to build a model first.")
            } else {
                pred <- predict(modFit, training)
                return(paste(
                    "RMSE on training samples: ",
                    RMSE(pred, training$height)
                ))
            }
        }
    })
    output$textPrediction <-  reactive({
        if (input$predictButton) {
            modFit <- model()
            if (is.null(modFit)) {
                return("You have to build a model first.")
            } else {
                toPred <-
                    data.frame(
                        age = as.numeric(input$ageValue),
                        foot_length = as.numeric(input$footLengthValue),
                        gender = input$genderValue
                    )
                pred <- predict(modFit, toPred)
                return(paste("The predicted Height (in cm) is ", pred[[1]]))
            }
        }
    })
    output$modelOutput <- renderPrint({
        modFit <- model()
        if (!is.null(modFit)) {
            return(summary(modFit$finalModel))
        }
    })
    output$plotModel <- renderPlot({
        modFit <- model()
        if (!is.null(modFit)) {
            predicted <- predict(modFit, training)
            predictedDF <-
                data.frame(pred_height = predicted, age = training$age)
            g <-
                ggplot(training, aes(y = height)) + scale_color_brewer(palette = pal)
            g <-
                g + geom_point(aes(x = age, colour = gender)) + ggtitle("Predicted Height") + xlab("Age") + ylab("Height")
            g + geom_smooth(
                color = 'green',
                data = predictedDF,
                aes(x = age, y = pred_height),
                size = 2
            )
        }
    })
    output$plotHeightFootLength <- renderPlot({
        anthropometry <- anthropometry[complete.cases(anthropometry), ]
        g <-
            ggplot(anthropometry, aes(y = height)) + scale_color_brewer(palette = pal)
        g <-
            g + geom_point(aes(x = foot_length, colour = gender)) + ggtitle("Height by Foot Length") + xlab("Foot length") + ylab("Height")
        if (!is.null(modelFootLength())) {
            intrcpt <- coef(modelFootLength())["(Intercept)"]
            slp <-  coef(modelFootLength())["foot_length"]
            g <-
                g + geom_abline(
                    slope = slp,
                    intercept = ,
                    color = "green",
                    size = 2
                )
        }
        g
    })
    output$slopeOut <- reactive({
        if (!is.null(modelFootLength())) {
            return(paste(coef(modelFootLength())["foot_length"]))
        }
    })
    output$interceptOut <- reactive({
        if (!is.null(modelFootLength())) {
            return(paste(coef(modelFootLength())["(Intercept)"]))
        }
    })
    output$plot1 <- renderPlot({
        anthropometry <- anthropometry[complete.cases(anthropometry), ]
        g <-
            ggplot(anthropometry, aes(y = height)) + scale_color_brewer(palette = pal)
        g + geom_point(aes(x = age, colour = gender)) + ggtitle("Height by Age") + xlab("Age") + ylab("Height")
    })
    output$plot2 <- renderPlot({
        anthropometry <- anthropometry[complete.cases(anthropometry), ]
        g <-
            ggplot(anthropometry, aes(y = height)) + scale_color_brewer(palette = pal)
        g + geom_point(aes(x = foot_length, colour = gender)) + ggtitle("Height by Foot length") + xlab("Foot length") + ylab("Height")
    })
    output$plot3 <- renderPlot({
        anthropometry <- anthropometry[complete.cases(anthropometry), ]
        g <-
            ggplot(anthropometry, aes(y = height)) + scale_fill_brewer(palette = pal)
        g + geom_boxplot(aes(x = gender, fill = gender)) + ggtitle("Height by Gender") + xlab("Gender") + ylab("Height")
    })
})