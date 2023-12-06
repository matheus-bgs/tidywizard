#' Helper functions for the tidywizard app
#'
#' @importFrom stringr str_replace_all
#' @importFrom stringr str_extract_all
#'
#' @export
#'
#' @returns useful functions for tidywizard

logical_condition <- function(input_condition){
  switch(input_condition,
         "igual a" = "==",
         "maior que" = ">",
         "menor que" = "<",
         "maior ou igual a" = ">=",
         "menor ou igual a" = "<=",
         "diferente de" = "!="
  )
}

escape_special_chars <- function(user_input) {
  # Define um vetor de possíveis caracteres especiais
  special_chars <- c(".", "+", "*", "?", "(", ")", "[", "]", "{", "}", "|", "^", "$")

  # Define um vetor de padrões para verificar
  pattern <- paste0("(\\", paste0(special_chars, collapse = "|\\"), ")")

  # Define qual o padrão que é similar
  matches <- stringr::str_extract_all(user_input, pattern) |> unlist()

  # Caso exista ao menos um match
  if(length(matches) > 0){
    # Altera o user_input para um user_input com o escape "\\" antes do caractere especial
    escaped_input <- stringr::str_replace_all(user_input, pattern = paste0("\\", matches), paste0("\\\\\\\\", matches))

    return(escaped_input)
    }

  # Se não houver um match, retorna o user_input inicial
  return(user_input)
}
