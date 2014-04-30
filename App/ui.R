library(shiny)
library(maps)
library(ggplot2)

# Define UI for Twitter content
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Choose a topic to follow on Twitter"),
  
  # Sidebar with control to type in a topic (by default we have a happy face)
  sidebarLayout(
    sidebarPanel(
      textInput("contentText", "Enter search term:", value = ":)"),
      
      submitButton("updateData","Search"), 
      
      helpText("This updates every 10 seconds, so please be patient.")
      
    ),
        
# Show a map of the World
    mainPanel(
      plotOutput("worldMap"),
      tableOutput("view")
    )
  )
))