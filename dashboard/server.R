list.of.packages <- c('shiny', 'ggplot2', 'dplyr', 'tidyr', 'lubridate')
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,'Package'])]
if(length(new.packages)) install.packages(new.packages)
suppressWarnings(suppressMessages(sapply(list.of.packages, library, character.only = T) -> .shh))

setwd('..')
source('getMESA_data.R')

files <- datafeed_get_files()

shinyServer(function(input, output) {
  dataset <- reactivePoll(30 * 1000, NULL, # check every 30 seconds whether it's time for an update
    checkFunc = function(){floor_date(Sys.time() - 30, unit = '5 mins')}, # server updates every 5 minutes on the 5's -- we'll wait 30 extra seconds to allow for clock diffs
    valueFunc = function(){
        datafeed_download_file(files) %>% gather(tags, value, -monitor, -date, na.rm = T) %>% filter(date > Sys.time() - 72*60*60)
        }
    )

  # Timeseries plot
  output$tsplot <- renderPlot({
      x.min <- .POSIXct(Sys.time(), "UTC") - (input$starttime*60*60)
      x.max <- .POSIXct(Sys.time(), "UTC") - (input$stoptime*60*60)
      ts.plt <- ggplot(
        dataset()[which(dataset()$tags %in% input$channel & dataset()$date <= x.max & dataset()$date >= x.min),]
      ) +
      geom_line(aes_string(x='date', y='as.numeric(value)', color = 'tags')) +
      geom_point(aes_string(x='date', y='as.numeric(value)', color = 'tags')) +
      facet_wrap(~monitor, ncol = 1) +
      theme_minimal() +
      xlab('time') +
      ylab('val') +
      coord_cartesian(xlim = c(x.min, x.max)) +
      ggtitle(paste('Data as of', as.character(max(dataset()$date)), 'UTC')) +
      theme(legend.position="top", strip.text = element_text(size=14, face="bold"))


    print(ts.plt)
  }, height = 1500)

  renderText

})
