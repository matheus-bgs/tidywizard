#' Launch tidywizard
#'
#' @returns Launches the tidywizard shiny application
#' @export
#'
#' @example
#' ## Not run:
#' tidywizard()

tidywizard <- function(){
  runApp("R/tidywizard_app.R")
}
