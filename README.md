# Boston Crime Analysis

## Overview

This is a Shiny web application designed for analyzing crime data in Boston. The application allows users to explore various aspects of crime data, including offense code groups, shootings, crime trends by date, UCR (Uniform Crime Reporting) parts, and streets with the highest and lowest crime rates. Additionally, it provides a heatmap representation of crimes in Boston.

## Try It Online

You can try the application online by clicking <a href="https://rashid01.shinyapps.io/crime/" target="_blank">here</a>.

**Note:** The website may take a few moments to load the first time you access it.

 
## Libraries and Data Loading

The application begins by loading necessary libraries such as `shiny`, `dplyr`, `ggplot2`, `leaflet`, and `scales`. These libraries are essential for data manipulation, visualization, and creating interactive maps.

Data is loaded from multiple CSV files using the `preprocess_shooting_data` function. This function reads each CSV file, standardizes the shooting values to "YES" or "NO," and combines the data into a single dataframe called `crime_data`.

## User Interface (UI)

The UI of the application is defined using the `fluidPage` function. It includes:

### Sidebar Panel

- A dropdown menu (`selectInput`) that allows users to select a specific year or choose "All" years for analysis.

### Main Panel

- Multiple tabs (`tabsetPanel`) for displaying different types of crime analyses, including offense code groups, shootings, crime trends by date, UCR parts, streets, and a heatmap.

## Server Function

The server function is responsible for processing and rendering the data based on user input. Here's how it works for each tab:

### Offense Code Group Tab

- Displays a table of offense code groups sorted by count.

### Shooting Tab

- Generates a bar chart showing the distribution of shootings (YES or NO) in the selected data.

### Crimes by Date Tab

- Displays a line graph depicting the count of crimes over time.

### UCR_Part Tab

- Shows a table of UCR parts sorted by count and includes a percentage column.

### Streets Tab

- Presents a table of streets sorted by the number of crimes.

### Heatmap Tab

- Creates an interactive heatmap of crimes in Boston using Leaflet. It allows users to visualize crime density on a map.

## Filtering Data

Data is filtered based on the selected year, and rows with empty or invalid street names are removed to ensure data quality.

## Conclusion

This Shiny web application provides a comprehensive analysis of crime data in Boston, offering insights into various aspects of crime trends. Users can explore the data interactively and gain a better understanding of crime patterns in the city.
