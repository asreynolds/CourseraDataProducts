# Coursera Data Science 

## Data Products Course Project

Please view a short pitch for my app [here](http://asreynolds.github.io/CourseraDataProducts/index.html). The pitch consists of five slides, which can be navigated using the arrow keys.

Please view the app itself [here](https://asreynolds.shinyapps.io/DataProdApp).

### Goal

We allow the user to create a map showing various economic indicators across the United States (the 48 contiguous states), by county. This is an exercise in creating an interactive app. The user is able to select an indicator from a dropdown menu, a range of values which are of interest by manipulating a slider, and create the map by clicking "Go!". The user is then able to zoom in on an area of interest. The input slider is itself the output of user input; the dropdown menu determines the possible range of values.

### Data

The data comes from the US Department of Agriculture and is available for download [here](http://www.ers.usda.gov/data-products/atlas-of-rural-and-small-town-america/download-the-data.aspx). The link to download the data used in this app includes several files. We only use Income.csv in this app. 

Documentation for the data, including definitions of poverty and deep poverty can be found [here](http://www.ers.usda.gov/data-products/atlas-of-rural-and-small-town-america/documentation.aspx#pov").

### Methods

The app was created using the R package `shiny` and is hosted on the shinyapps.io server. The user interface is defined in ui.R and the server calculations are defined in server.R. The map is drawn using the `ggplot2`, `maps`, and `mapproj` packages.

The options appearing in the dropdown menu are the economic indicators forming the columns of Income.csv. Once an indicator is selected, the maximum value available on the slider is adjusted appropriately. For percentage indicators, the maximum is 100. For all other indicators, the maximum is the maximum value of the indicator chosen. The range selected is then divided into five subintervals of equal length, forming the five levels determining the coloration of the map, as indicated by the legend. Note that if a range is selected so that no county lies in that range (this is possible for the percentage indicators), then fewer colors than five will be drawn. For example, selecting "Percent in Poverty (under 18)" and the range 91 - 100, only one color appears, reflecting the fact that "92.8 percent or less" of children are in poverty in all counties across the nation.

Once the map has been drawn, the user is able to zoom in by selecting the desired rectangular viewing window. This is done by holding the mouse button and dragging the cursor. Once the desired viewing window has been specified, the user clicks "Go!" again to redraw the map, showing only those counties in the specified viewing window. To zoom back out, the user clicks "Go!" once again, without any viewing window selected.
