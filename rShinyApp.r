#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

# Rashid Mammadov

# Define UI for application that draws a histogram
library(shiny)
library(dplyr)
library(ggplot2)
library(leaflet)
library(leaflet.extras)
library(scales)


# Load all the CSV files and combine them into one dataframe
preprocess_shooting_data <- function(file) {
  data <- read.csv(file)
  
  # Convert factors to character (if applicable)
  if (is.factor(data$SHOOTING)) {
    data$SHOOTING <- as.character(data$SHOOTING)
  }
  
  # Standardize shooting values
  data <- data %>% 
    mutate(SHOOTING = ifelse(SHOOTING == "Y" | SHOOTING == 1, "YES", "NO"))
  
  return(data)
}

filenames <- c("2015.csv", "2016.csv", "2017.csv", "2018.csv", "2019.csv", "2020.csv", "2021.csv", "2022.csv", "2023.csv")
crime_data <- do.call("rbind", lapply(filenames, preprocess_shooting_data))



ui <- fluidPage(
  titlePanel("Boston Crime Analysis"),
  
  sidebarLayout(
    sidebarPanel(
      h3("Questions"),
      selectInput("year", "Select Year:", choices = c("All", 2015:2023), selected = "All")
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Offense Code Group",
                 h4("Which kind of offense_code_group happens the most/least?"),
                 tableOutput("offense_summary")),
        tabPanel("Shooting",
                 h4("Barchart of shooting"),
                 plotOutput("shooting_bar")),
        tabPanel("Crimes by Date",
                 h4("Line graph of dates of crimes"),
                 plotOutput("crimes_date_line")),
        tabPanel("UCR_Part",
                 h4("Which UCR_Part happens the most?"),
                 tableOutput("ucr_summary")),
        tabPanel("Streets",
                 h4("Which street has the most crimes? Which one has the least?"),
                 tableOutput("street_summary")),
        tabPanel("Heatmap",
                 h4("Draw a heatmap for crimes"),
                 leafletOutput("crime_heatmap"))
      )
    )
  )
)

server <- function(input, output) {
  
  filtered_data <- reactive({
    if (input$year == "All") {
      data <- crime_data
    } else {
      data <- crime_data %>% filter(YEAR == input$year)
    }
    # Remove rows with empty (NA) values or blank/whitespace strings in the STREET column
    data <- data %>% filter(!is.na(STREET) & STREET != "" & !grepl("^\\s*$", STREET), STREET != "LONG ISLAND RD" )
    return(data)
  })
  
  
  # Offense Code Group
  output$offense_summary <- renderTable({
    offense_summary <- filtered_data() %>% 
      count(OFFENSE_DESCRIPTION, sort = TRUE) %>%
      rename("OFFENSE DESCRIPTION" = OFFENSE_DESCRIPTION,
             "Count" = n)
    return(offense_summary)
  })
  
  # Shooting Barchart
  output$shooting_bar <- renderPlot({
    shooting_bar <- filtered_data() %>% 
      count(SHOOTING, sort = TRUE) %>%
      ggplot(aes(x = SHOOTING, y = n, fill = SHOOTING)) +
      geom_bar(stat = "identity") +
      theme_minimal() +
      labs(title = "Shootings",
           x = "Shooting",
           y = "Count",
           fill = "Shooting")
    return(shooting_bar)
  })
  
  # Crimes by Date Line Graph
  output$crimes_date_line <- renderPlot({
    crimes_date <- filtered_data()
    crimes_date$OCCURRED_ON_DATE <- as.Date(crimes_date$OCCURRED_ON_DATE)
    
    crimes_date_line <- crimes_date %>%
      count(OCCURRED_ON_DATE) %>%
      ggplot(aes(x = OCCURRED_ON_DATE, y = n)) +
      geom_line() +
      theme_minimal() +
      labs(title = "Crimes by Date",
           x = "Date",
           y = "Count")
    return(crimes_date_line)
  })
  
  # UCR_Part
  output$ucr_summary <- renderTable({
    ucr_summary <- filtered_data() %>%
      count(UCR_PART, sort = TRUE) %>% arrange(desc(n))%>%mutate(prop = percent(n/nrow(crime_data)))%>%
      rename("UCR Part" = UCR_PART,
             "Count" = n)
    return(ucr_summary)
  })
  
  # Streets
  output$street_summary <- renderTable({
    street_summary <- filtered_data() %>%
      count(STREET, sort = TRUE) %>%
      rename("Street" = STREET,
             "Count" = n)
    return(street_summary)
  })
  
  # Heatmap
  output$crime_heatmap <- renderLeaflet({
    # Create a custom gradient with transparency (alpha)
    transparent_gradient <- colorBin(palette = "YlOrRd", domain = 0:1, bins = 10, na.color = "transparent", alpha = 0.5)
    
    m <- leaflet(filtered_data()) %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      setView(lng = -71.0589, lat = 42.3601, zoom = 12) %>%
      addHeatmap(data = filtered_data()[!is.na(filtered_data()$Lat) & !is.na(filtered_data()$Long),  c("Lat", "Long")],
                 blur = 22.5, max = 0.5, radius = 15,gradient = NULL)%>%
      addTiles()
    return(m)
  })
}
shinyApp(ui = ui, server = server)
