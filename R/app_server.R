#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  # Your application server logic
  
  r <- reactiveValues(fct = NULL)
  
  mod_function_selector_server("function_selector", r)
  mod_function_inputs_server("function_inputs", r)
}
