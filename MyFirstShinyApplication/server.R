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

anthropometry <- anthropometry[complete.cases(anthropometry),]
inTrain = createDataPartition(anthropometry$height, p = 0.8)[[1]]
testing = anthropometry[-inTrain,]
training = anthropometry[ inTrain,]

trainCtrl <- trainControl(method = "cv", savePredictions = "none", number=3)

pal <- "Set1"

shinyServer(function(input, output) {
    model <- reactive({
        if (input$buildModelButton) {
            selMethod <-input$modelInput
            
            selPred <- c()
            if(input$addFootLength) {
                selPred <- c(selPred, "foot_length")
            }
            if(input$addAge) {
                selPred <- c(selPred, "age")
            }
            if(input$addGender) {
                selPred <- c(selPred, "gender")
            }
            
            if(length(selPred) == 0) {
                return(NULL)
            }
            selFormula <- as.formula(paste("height", paste(selPred, collapse=" + "), sep=" ~ "))
            modFit <- train(selFormula, method=selMethod, data=training, trControl=trainCtrl, model = FALSE)
    
            modFit
        } else {
            return(NULL)
        }
    })
    output$textPrediction <-  reactive({
        if (input$predictButton) {
            modFit <- model()
            if (is.null(modFit)) {
                return("You have to build a model first.")
            } else {
                toPred <- data.frame(age = as.numeric(input$ageValue), foot_length = as.numeric(input$footLengthValue), gender=input$genderValue)
                predict(modFit, toPred)

            }
        }
    })
    output$plotModel <- renderPlot({
        modFit <- model()
        if(!is.null(modFit)){
            predicted <- predict(modFit, training)
            predictedDF <- data.frame(pred_height = predicted, age=training$age)
            g <- ggplot(training, aes(y=height)) + scale_color_brewer(palette=pal)
            g <- g + geom_point(aes(x=age, colour=gender)) + ggtitle("Predicted Height")
            g + geom_smooth(color='green', data = predictedDF, aes(x=age, y=pred_height))
        }
    })
    output$plot1 <- renderPlot({
        anthropometry <- anthropometry[complete.cases(anthropometry),]
        g <- ggplot(anthropometry, aes(y=height)) + scale_color_brewer(palette=pal)
        g + geom_point(aes(x=age, colour=gender)) + ggtitle("Height by Age")
    })
    output$plot2 <- renderPlot({
        anthropometry <- anthropometry[complete.cases(anthropometry),]
        g <- ggplot(anthropometry, aes(y=height)) + scale_color_brewer(palette=pal)
        g + geom_point(aes(x=foot_length, colour=gender)) + ggtitle("Height by Foot Length")
    })
    output$plot3 <- renderPlot({
        anthropometry <- anthropometry[complete.cases(anthropometry),]
        g <- ggplot(anthropometry, aes(y=height)) + scale_fill_brewer(palette=pal)
        g + geom_boxplot(aes(x=gender, fill=gender)) + ggtitle("Height by Gender")
    })
})