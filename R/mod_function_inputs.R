#' function_inputs UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_function_inputs_ui <- function(id){
  ns <- NS(id)
  tagList(
    uiOutput(ns("output_fct_inputs"))
  )
}
    
#' function_inputs Server Functions
#'
#' @noRd 
mod_function_inputs_server <- function(id, r){
  moduleServer(id, function(input, output, session){
    ns <- session$ns
    
    output$output_fct_inputs <- renderUI({
      func <- r$fct
      
      switch(
        func,
        "select" = tagList(
          shinyWidgets::pickerInput(
            inputId = ns("picker_column"),
            label = div(icon("pen-to-square"), "Choose Column(s)"), 
            choices = names(mtcars),
            multiple = TRUE,
            options = list(
              title = "Choose column(s)"
            )
          )
        ),
        "filter" = tagList(
          shinyWidgets::pickerInput(
            inputId = ns("picker_column"),
            label = div(icon("pen-to-square"), "Choose a Column"),
            choices = names(mtcars),
            options = list(
              title = "Choose column(s)"
            )
          )
        )
      )
    })
  })
}
    
## To be copied in the UI
# mod_function_inputs_ui("function_inputs")
    
## To be copied in the server
# mod_function_inputs_server("function_inputs")
