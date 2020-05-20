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

trainCtrlGlm <- trainControl(method = "cv", savePredictions = "none", number=5)
trainCtrlOthers <- trainControl(method = "cv", savePredictions = "none", number=2)

glmFit <- train(height ~ ., method="glm", data=training, trControl=trainCtrlGlm, model = FALSE)
#rfFit <- train(height ~ ., method="rf", data=training, trControl=trainCtrlOthers, model = FALSE)
gbmFit <- train(height ~ ., method="gbm", data=training, trControl=trainCtrlOthers, model = FALSE)

shinyServer(function(input, output) {
    model <- reactive({
        data <- switch(input$modelInput, 
                       "glm" = modFit,
                       "gbm" = modFit,
                       "rf" = modFit)
        data

#        if(nrow(brushed_data) < 2){
#            return(NULL)
#        }
#        lm(Volume ~ Girth, data = brushed_data)
    })
    output$plotModel <- renderPlot({
        modFit <- model()
        predicted <- predict(modFit, training)
        predictedDF <- data.frame(pred_height = predicted, age=training$age)
        g <- ggplot(training, aes(y=height)) + scale_color_brewer(palette=pal)
        g <- g + geom_point(aes(x=age, colour=gender)) + ggtitle("Predicted Height")
        g + geom_line(color='green', data = predictedDF, aes(x=pred_height, y=age))
        
    })
    output$plot1 <- renderPlot({
        pal <- "Set1"
        anthropometry <- anthropometry[complete.cases(anthropometry),]
        g <- ggplot(anthropometry, aes(y=height)) + scale_color_brewer(palette=pal)
        g + geom_point(aes(x=age, colour=gender)) + ggtitle("Height by Age")
#        plot(anthropometry$height, anthropometry$age, xlab = "Height",
#             ylab = "Age", main = "Tree Measurements",
#             cex = 1.5, pch = 16, bty = "n")
#        if(!is.null(model())){
#            abline(model(), col = "blue", lwd = 2)
#        }
    })
    output$plot2 <- renderPlot({
        pal <- "Set1"
        anthropometry <- anthropometry[complete.cases(anthropometry),]
        g <- ggplot(anthropometry, aes(y=height)) + scale_color_brewer(palette=pal)
        g + geom_point(aes(x=foot_length, colour=gender)) + ggtitle("Height by Foot Length")
#        plot(anthropometry$height, anthropometry$foot_length, xlab = "Height",
#             ylab = "Foot Length", main = "Tree Measurements",
#             cex = 1.5, pch = 16, bty = "n")
#        if(!is.null(model())){
#            abline(model(), col = "blue", lwd = 2)
#        }
    })
    output$plot3 <- renderPlot({
        pal <- "Set1"
        anthropometry <- anthropometry[complete.cases(anthropometry),]
        g <- ggplot(anthropometry, aes(y=height)) + scale_fill_brewer(palette=pal)
        g + geom_boxplot(aes(x=gender, fill=gender)) + ggtitle("Height by Gender")
        #        plot(anthropometry$height, anthropometry$gender, xlab = "Height",
        #             ylab = "Gender", main = "Tree Measurements",
        #             cex = 1.5, pch = 16, bty = "n")
        #        if(!is.null(model())){
        #            abline(model(), col = "blue", lwd = 2)
        #        }
    })
})