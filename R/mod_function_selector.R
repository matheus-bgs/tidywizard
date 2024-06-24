#' function_selector UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_function_selector_ui <- function(id){
  ns <- NS(id)
  tagList(
    shinyWidgets::pickerInput(
      inputId = ns("picker_fct"),
      label = div(icon("pen-to-square"), "Choose a Function"), 
      choices = c("Select - Select columns" = "select",
                  "Filter - Filter rows" = "filter"),
      options = list(
        title = "Choose a function"
        )
      )#,
    # verbatimTextOutput(ns("test_fct"))
  )
}
    
#' function_selector Server Functions
#'
#' @noRd 
mod_function_selector_server <- function(id, r){
  moduleServer(id, function(input, output, session){
    ns <- session$ns
 
    observe(
      r$fct <- input$picker_fct
    ) |> 
      bindEvent(input$picker_fct)
    
    # output$test_fct <- renderPrint({
    #   print(r$fct)
    # })
  })
}
    
## To be copied in the UI
# mod_function_selector_ui("function_selector_1")
    
## To be copied in the server
# mod_function_selector_server("function_selector_1")
