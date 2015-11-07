library(ggplot2)
library(maps)
library(mapproj)

mapcounties <- map_data("county")
mapstates <- map_data("state")

income <- read.csv("data/Income.csv", fileEncoding="latin1")
income <- income[income$FIPS %in% county.fips$fips,]
income$State <- state.name[match(income$State, state.abb)]

income$county <- tolower(with(income , paste(State, County, sep = ",")))
mapcounties$county <- with(mapcounties , paste(region, subregion, sep = ","))

mergedata <- merge(mapcounties, income, by.x = "county")
mergedata <- mergedata[order(mergedata$order),]

shinyServer(
    function(input, output) {
        output$menu <- renderUI({
            selectInput("var", label = strong("Choose an indicator to display"),
                        choices = list( "Median Household Income",
                                        "Per Capita Income",
                                        "Percent in Poverty (under 18)",
                                        "Percent in Poverty (all ages)",
                                        "Percent in Deep Poverty (all ages)",
                                        "Percent in Deep Poverty (under 18)",
                                        "Total in Poverty (under 18)",
                                        "Total in Poverty (all ages)"),
                        selected = "Median Household Income")
        })
        
        
        output$slider <- renderUI({
            max.slider <- if (is.null(input$var)) {117680}
            else if (input$var == "Median Household Income") {117680} 
            else if (input$var == "Per Capita Income") {62498}
            else if (input$var == "Total in Poverty (under 18)") {624784}
            else if (input$var == "Total in Poverty (all ages)") {1872964}
            else 100
            
            sliderInput("slider", "Range of interest:",
                        min = 0, max = max.slider, value = c(0, max.slider))
        })
        
        # The map is drawn when user clicks "Go!"
        mymap <- eventReactive(input$go, { 
            if (is.null(input$var)) {return()}
            # data used in coloring the map
            data <- switch(input$var, 
                           "Median Household Income" = cbind(mergedata[1:5], 
                                                             x = pmax(pmin(mergedata$MedHHInc2013, 
                                                                           input$slider[2]), input$slider[1])),
                           "Per Capita Income" = cbind(mergedata[1:5], 
                                                       x = pmax(pmin(mergedata$PerCapitaInc, 
                                                                     input$slider[2]), input$slider[1])),
                           "Percent in Poverty (under 18)" = cbind(mergedata[1:5], 
                                                                   x = pmax(pmin(mergedata$PovertyUnder18Pct2013, 
                                                                                 input$slider[2]), input$slider[1])),
                           "Percent in Poverty (all ages)" = cbind(mergedata[1:5], 
                                                                   x = pmax(pmin(mergedata$PovertyAllAgesPct2013, 
                                                                                 input$slider[2]), input$slider[1])),
                           "Percent in Deep Poverty (all ages)" = cbind(mergedata[1:5], 
                                                                        x = pmax(pmin(mergedata$Deep_Pov_All, 
                                                                                      input$slider[2]), input$slider[1])),
                           "Percent in Deep Poverty (under 18)" = cbind(mergedata[1:5], 
                                                                        x = pmax(pmin(mergedata$Deep_Pov_Children, 
                                                                                      input$slider[2]), input$slider[1])),
                           "Total in Poverty (under 18)" = cbind(mergedata[1:5], 
                                                                 x = pmax(pmin(mergedata$PovertyUnder18Num2013, 
                                                                               input$slider[2]), input$slider[1])),
                           "Total in Poverty (all ages)"= cbind(mergedata[1:5], 
                                                                x = pmax(pmin(mergedata$PovertyAllAgesNum2013, 
                                                                              input$slider[2]), input$slider[1])))
            # color scheme for the map
            color <- switch(input$var, 
                            "Median Household Income" = "Blues",
                            "Per Capita Income" = "Greens",
                            "Percent in Poverty (under 18)" = "RdPu",
                            "Percent in Poverty (all ages)" = "Reds",
                            "Percent in Deep Poverty (all ages)" = "Greys",
                            "Percent in Deep Poverty (under 18)" = "Purples",
                            "Total in Poverty (under 18)" = "YlOrRd",
                            "Total in Poverty (all ages)" = "BuGn")
            
            # increment between colors in the legend
            increment <- (input$slider[2] - input$slider[1])/5
            # viewing window
            ranges <- reactiveValues(x = NULL, y = NULL)
            brush <- input$mapbrush
            if (!is.null(brush)) {
                ranges$x <- c(brush$xmin, brush$xmax)
                ranges$y <- c(brush$ymin, brush$ymax)
            } else {
                ranges$x <- NULL
                ranges$y <- NULL
            }
            
            #color the map
            map <- ggplot(data, aes(long, lat, group=group)) +
                geom_polygon(aes(fill=cut(x,5))) + 
                scale_fill_brewer(palette = color, name = input$var,
                                  labels = c(
                                      paste(as.character(input$slider[1] + increment), 
                                            "or less"),
                                      as.character(input$slider[1] + increment * 2),
                                      as.character(input$slider[1] + increment * 3),
                                      as.character(input$slider[1] + increment * 4),
                                      paste(as.character(input$slider[1] + increment * 5), 
                                            "or more")
                                  )) +
                coord_cartesian(xlim = ranges$x, ylim = ranges$y)
            
            #add borders
            map <- map + geom_path(data = mapstates, colour = "white", size = .5) + 
                geom_path(data = mapcounties, colour = "white", 
                          size = .25, alpha = .1)
            map
        })
        
        output$map <- renderPlot({
            mymap()
        })
    })