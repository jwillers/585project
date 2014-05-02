library(shiny)
library(maps)
library(ROAuth)
library(streamR)

## Prepare the stream - this section commented out to display ability 
## to create the credentials file
# requestURL <- "https://api.twitter.com/oauth/request_token"
# accessURL <- "https://api.twitter.com/oauth/access_token"
# authURL <- "https://api.twitter.com/oauth/authorize"
# consumerKey <- "YOURKEY"
# consumerSecret <- "YOURSECRET"
# my_oauth <- OAuthFactory$new(consumerKey=consumerKey,
#                              consumerSecret=consumerSecret, 
#                              requestURL=requestURL,
#                              accessURL=accessURL, 
#                              authURL=authURL)
# my_oauth$handshake(cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl"))

# Save the credentials to a file
# save(my_oauth, file="credentials.RData")

# Load the previously saved credentials file
load(file="credentials.RData")

# Contruct a data frame using the filterStream function. This is a nice base to start from
tempTweets <- filterStream( file.name="", locations=c(-180,-90,180,90), tweets=10, oauth=my_oauth )
parsedList <- parseTweets(tempTweets)

# Initialize an empty data frame
datalist <- head(parsedList,0)

## The main function for the map
shinyServer(function(input, output, session) {
  # Take the data frame and make a reactive counterpart
  values<-reactiveValues()
  values$datalist <- datalist
  
  autoTime <- reactiveTimer(11000, session)
  
  # Make the map
  output$worldMap <- renderPlot({
    map('world')
    # Make sure to show only when we have data
    if (nrow(values$datalist)>0) {
      # Make the points
      points(values$datalist$place_lon, values$datalist$place_lat, pch = 21, bg="red", cex=2)
    }
  })

  # Check the feed
  observe ({
    # First set this to run with autoTime
    autoTime()
    
    # Check the stream
    tempTweets <- filterStream( file.name="", track=input$contentText, timeout=9, oauth=my_oauth )
    
    # Test the stream for session errors and data. If there is data, parse it
    if(any(tempTweets == "Easy there, Turbo. Too many requests recently. Enhance your calm.")) {
      parsedList <- data.frame("Session error, please wait")
      Sys.sleep(3)
    }
    else if ((length(tempTweets)>0) & (any(tempTweets != "Exceeded connection limit for user"))) {
      parsedList <- parseTweets(tempTweets)
      parsedList <- subset(parsedList, !is.na(parsedList$place_lon))
      
      # totalList has parsed tweets with locative coordinates
      if (input$addData) {
        values$datalist <- rbind(parsedList,isolate(values$datalist))
      } else {
        values$datalist <- parsedList
      }
    }
  })  
    
  
  output$view <- renderTable({
    if (nrow(values$datalist)>0) {
      values$datalist
    }
    else data.frame("No results yet. You can wait or enter a new search term.")
  })
  
  
})
