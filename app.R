library(shiny)
library(DT)
library(rapiclient)
library(httr)
library(jsonlite)
library(tidyverse)
library(magrittr)


ui <- basicPage(
    h2("Dockstore tools"),
    dataTableOutput("mytable")
)


server <- function(input, output) {
    
    ds_api     <- get_api(url = "https://dockstore.org:8443/swagger.json")
    operations <- get_operations(ds_api)
    entries    <- operations$entriesOrgGet("ga4gh-dream")
    entries_df <- fromJSON(content(entries, as = 'text'))
    tools      <- operations$toolsOrgGet("ga4gh-dream")
    tools_df   <- fromJSON(content(tools, as = 'text'))
    columns    <- c("name", "author", "url", "gitUrl", "path")
    
    combined_df <- 
        inner_join(
            tools_df, 
            entries_df, 
            by = c("name" = "toolname", "author")) %>% 
        select_(.dots = columns) %>% 
        as_data_frame
    
    output$mytable = renderDataTable(combined_df)
    
}

shinyApp(ui = ui, server = server)

