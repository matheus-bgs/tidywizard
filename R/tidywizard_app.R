#' The main tidywizard app
#' @import shiny
#' @import bs4Dash
#' @import rintrojs
#' @import here
#' @import dplyr
#' @import tidyr
#' @import rclipboard
#' @import tippy
#'
#' @returns Defines the tidywizard shiny application

intro <- readr::read_csv2(here::here("inst/intro.csv"),
                          locale = readr::locale(encoding = "latin1"))

df <- ggplot2::mpg

choices_fct <- c("select - Selecione colunas",
                 "filter - Filtre linhas",
                 "arrange - Ordene as colunas",
                 "count - Conte os valores",
                 "rename - Renomeie colunas",
                 "mutate - Crie/altere colunas",
                 "summarise - Resuma seus dados",
                 "separate - Separe uma coluna",
                 "unite - Junte colunas")

numeric_summs <- c("mean", "median", "standard deviation",
                   "variance", "minimum", "maximum")

mutate_choices <- c("Operações numéricas",
                    "Operações com funções"
                    # "Conversão de classes",
                    # "Somatórios",
                    # "'Se, senão' (If, else)"
)

ui <- dashboardPage(
  freshTheme = TRUE,
  help = NULL,
  dark = NULL,
  ## Header
  bs4Dash::bs4DashNavbar(title = bs4DashBrand(HTML("<strong>tidywizard</strong>"), opacity = 1, color = "primary",
                                              image = knitr::image_uri(here::here("inst/logo_tidywizard.png"))),
                         actionButton(inputId = "BTN_RESET", label = "Botão de Reset", icon = icon("backward-fast")),
                         actionButton(inputId = "BTN_BACK", label = "Voltar uma transformação", icon = icon("rotate-left"))
  ),
  ## Sidebar
  dashboardSidebar(width = "200",
                   collapsed = T, id = "sidebar_id",
                   sidebarMenu(id = "TABS",
                               # menuItem(tabName = "TAB_HOME",
                               #   "Home", icon = icon("house")
                               # ),
                               menuItem(tabName = "TAB_DATA",
                                        "Data Manipulation", icon = icon("filter")
                               )#,
                               # menuItem(tabName = "TAB_SHEET",
                               #   "Cheat Sheet", icon = icon("note-sticky")
                               # )
                   )
  ),

  ## Body
  bs4Dash::bs4DashBody(
    ## INTRO TOUR ----
    rintrojs::introjsUI(),
    tags$head(
      tags$style(
        HTML("
      .tour_button {
        font-weight: bold;
        color:white;
      }"))
    ),

    ## ITEMS ----
    tabItems(
      tabItem(tabName = "TAB_DATA",
              fluidRow(
                column(
                  width = 7,
                  fluidRow(
                    rintrojs::introBox(data.step = 1, data.intro = intro$text[1],
                                       data.position = "right",
                                       box(
                                         id = "div_box_escolha_funcao",
                                         icon = icon("gears"),
                                         height = "110",
                                         width = NULL,
                                         title = "Escolha uma função",
                                         shiny::splitLayout(id = "div_split_botoes",
                                                            tags$head(
                                                              tags$style(
                                                                HTML(
                                                                  ".shiny-split-layout > div {
                                                                overflow: visible;
                                                               }"))),
                                                            selectInput("SELEC_FCT", label = NULL,
                                                                        width = "400px",
                                                                        choices = choices_fct),
                                                            cellWidths = c("0%", "50%", "50%"),
                                                            tooltip(actionButton("CHECK_FCT", label = "Selecione a função",
                                                                                 icon = icon("check")),
                                                                    title = "essa é uma dica!", placement = "top"
                                                            )
                                         )
                                         # div(style = "display:inline-block",
                                         #     selectInput("SELEC_FCT", label = NULL,
                                         #                 width = "200px",
                                         #                 choices = choices_fct)),
                                         # div(style = "display:inline-block",
                                         #     actionButton("CHECK_FCT", label = "Selecione a função",
                                         #                  style = "margin-top:-27px",
                                         #                  icon = icon("check")))
                                       )
                    )
                  ),
                  fluidRow(
                    introBox(data.step = 2, data.intro = intro$text[2],
                             data.position = "right",
                             bs4Dash::tabBox(id = "BOX_FUN_INPUTS", width = NULL, icon = icon("wand-magic-sparkles"),
                                             title = "Aplique a função", type = "pills",
                                             footer = splitLayout(id = "div_footer_split_botoes",
                                                                  actionButton(inputId = "BTN_ADD_TAB", icon = icon("plus"),
                                                                               label = "Adicionar variável"),
                                                                  actionButton(inputId = "BTN_RMV_TAB", icon = icon("minus"),
                                                                               label = "Remover variável"),
                                                                  rintrojs::introBox(data.step = 3, data.intro = intro$text[3],
                                                                                     data.position = "right",
                                                                                     actionButton(inputId = "EXEC_FCT", label = "Execute a função",
                                                                                                  icon = icon("filter"))
                                                                  )
                                             ),
                                             tabPanel(title = "Variável 1",
                                                      uiOutput("FUNCTION_INPUTS")
                                             )
                             )
                    )
                  )
                ),
                column(
                  width = 5,
                  # box(
                  #   height = "480",
                  #   width = NULL,
                  #   title = "Seus dados",
                  rintrojs::introBox(data.step = 4, data.intro = intro$text[4],
                                     data.position = "bottom",
                                     reactable::reactableOutput("DATA") |>
                                       shinycssloaders::withSpinner()
                  )
                )
                # )
              ),
              fluidRow(
                column(
                  width = 12,
                  rclipboard::rclipboardSetup(),
                  tippy_this("BTN_CLIPBOARD",
                             tooltip = "Copiado!",
                             trigger = "click"),
                  box(
                    collapsible = F,
                    height = "300",
                    width = NULL,
                    title = tagList(
                      splitLayout(id = "div_header_code_box",
                                  div(icon("code"), "Código de R", id = "div_icon_title_code_box"),
                                  uiOutput("BTN_CLIPBOARD"))
                    ),#"Código de R",

                    rintrojs::introBox(data.step = 5, data.intro = intro$text[5],
                                       data.position = "top",
                                       verbatimTextOutput("CODE")
                                       # verbatimTextOutput("DEBUG")
                    )
                  )
                )
              )
      )
    )
  )
)

server <- function(input, output, session){
  ## INTRO ----
  observeEvent("", {
    showModal(modalDialog(
      # includeHTML("../intro_text.html"),
      HTML(paste0(htmltools::div(style = 'position:relative;',
                                 img(src = knitr::image_uri(here::here("inst/logo_tidywizard.png")),
                                     style = 'display: block; margin-left: auto; margin-right: auto;',
                                     width = "30%")),
                  HTML('<h1 style="text-align: center;">Seja bem-vindo ao&nbsp;<code><strong>tidywizard</strong></code></h1>
                   <h4 style="text-align: center;">Uma aplicação com objetivo de facilitar a manipulação de dados enquanto o usuário aprende.<br>A forma de utilizar o tidywizard é simples: selecione e preencha as entradas conforme seu interesse para transformar os dados e o mago cuida do trabalho de traduzir isso para o R.<br>Depois disso, você pode conferir a fórmula do mago para executar o seu tratamento.</h4>
                   <hr />
                   <p style="text-align: left;font-size:20px;">O tidywizard está em processo de desenvolvimento, contudo ele já permite ao usuário fazer uso de funções corriqueiras do dia-a-dia da análise de dados, como <code>select</code> e <code>filter</code> do pacote <code>dplyr</code>.</a> </p>
                   <hr />
                   ')
      )),
      easyClose = TRUE,
      footer = tagList(
        splitLayout(
          actionButton(inputId = "BTN_SKIP_INTRO", label = "PULAR A INTRODUÇÃO", icon = icon("forward")),
          actionButton(inputId = "INTRO", label = "IR À INTRODUÇÃO", icon = icon("info-circle"))
        )
      )
    ))
  })

  observe(
    removeModal()
  ) |> bindEvent(input$BTN_SKIP_INTRO)


  observeEvent(input$INTRO, {
    removeModal()
  })

  observeEvent(input$INTRO, {
    introjs(
      session,
      options = list("nextLabel" = "Próximo",
                     "prevLabel" = "Anterior",
                     "doneLabel" = "Finalizar")
    )
  })

  ## SERVER ----
  observe({
    reactive_values$data <- reactive_values$data_reset
    reactive_values$code <- "df"

  }) |> bindEvent(input$BTN_RESET)

  observe({
    if(reactive_values$code != "df"){
      reactive_values$code <- stringr::str_remove(reactive_values$code, pattern = "\\s\\|>\\n.+$")
      reactive_values$data <- rlang::eval_tidy(rlang::parse_expr(reactive_values$code))
    }

  }) |> bindEvent(input$BTN_BACK)

  selected_function <- eventReactive(input$CHECK_FCT, {
    isolate({
      gsub("\\s*-.*", "", input$SELEC_FCT)
    })
  })

  reactive_values <- reactiveValues(data_reset = df,
                                    data = df,
                                    code = "df",
                                    cont_tabs = 1,
                                    mutate_type = NULL)


  output$FUNCTION_INPUTS <- renderUI({
    req(input$CHECK_FCT)

    if (selected_function() == "select") {
      # Renderizar os inputs específicos para a função select()
      # Exemplo: input para selecionar as colunas
      selectInput(inputId = "SELEC_COLS",
                  label = "Selecione a(s) coluna(s)",
                  choices = colnames(reactive_values$data),
                  multiple = TRUE)
    } else if (selected_function() == "filter") {
      # Renderizar os inputs específicos para a função filter()
      # Exemplo: inputs para selecionar a coluna, a condição e o valor
      tagList(
        selectInput(inputId = "SELEC_COL_FILTER",
                    label = "Selecione a coluna",
                    choices = colnames(reactive_values$data),
                    selected = NULL),
        selectInput(inputId = "SELEC_CONDT",
                    label = "Selecione a condição",
                    choices = c("igual a", "maior que", "menor que", "maior ou igual a", "menor ou igual a", "diferente de")),
        renderUI({
          selected_column <- input$SELEC_COL_FILTER
          column_class <- class(reactive_values$data[[selected_column]])

          switch(column_class,
                 "numeric" = numericInput(inputId = "FILTER_VALUE",
                                          label = "Valor a filtrar",
                                          value = 0),
                 "integer" = numericInput(inputId = "FILTER_VALUE",
                                          label = "Valor a filtrar",
                                          value = 0),
                 "character" = selectInput(inputId = "FILTER_VALUE",
                                           label = "Valor a filtrar",
                                           choices = unique(reactive_values$data[[selected_column]]),
                                           multiple = TRUE),
                 "factor" = selectInput(inputId = "FILTER_VALUE",
                                        label = "Valor a filtrar",
                                        choices = levels(reactive_values$data[[selected_column]])),
                 # Caso o tipo da coluna não seja numeric, character ou factor
                 p("Aviso: Tipo de coluna não suportado para filtro.")
          )
        })
      )
    } else if (selected_function() == "summarise"){
      tagList(
        selectInput(inputId = "SELEC_GROUP_BY", label = "Selecione uma coluna para agrupar",
                    multiple = TRUE, choices = colnames(reactive_values$data)),

        selectInput(inputId = "SELEC_COL_SUMM_1", label = "Selecione a coluna",
                    choices = colnames(reactive_values$data)),
        renderUI({
          selected_column_summ1 <- input$SELEC_COL_SUMM_1
          summ1_class <- class(reactive_values$data[[selected_column_summ1]])

          switch(summ1_class,
                 "numeric" = selectInput(inputId = "FCT_SUMM_1",
                                         label = "Selecione o tipo de sumarização",
                                         choices = numeric_summs),
                 "integer" = selectInput(inputId = "FCT_SUMM_1",
                                         label = "Selecione o tipo de sumarização",
                                         choices = numeric_summs),
                 "character" = selectInput(inputId = "FCT_SUMM_1",
                                           label = "Selecione o tipo de sumarização",
                                           choices = "contagem"),
                 "factor" = selectInput(inputId = "FCT_SUMM_1",
                                        label = "Selecione o tipo de sumarização",
                                        choices = "contagem"))
        })
      )
    } else if (selected_function() == "count"){
      # tooltip(title = "Caso você queira contar por grupos, selecione a coluna de agrupamento, e então a coluna que deve ser contada", placement = "right",
      selectInput(inputId = "SELEC_COLS_COUNT",
                  label = "Selecione a(s) coluna(s)",
                  choices = colnames(reactive_values$data),
                  multiple = TRUE)
      # )
    } else if (selected_function() == "arrange"){
      selectInput(inputId = "SELEC_COLS_ARRANGE",
                  label = "Selecione a(s) coluna(s)",
                  choices = colnames(reactive_values$data),
                  multiple = TRUE)
    } else if (selected_function() == "rename"){
      tagList(
        selectInput(inputId = "SELEC_COL_RENAME_1", label = "Selecione a coluna",
                    choices = colnames(reactive_values$data)),
        textInput(inputId = "TEXT_RENAME_COL_1", label = "Renomeie a coluna",
                  placeholder = "Escreva aqui")
      )
    } else if (selected_function() == "separate"){
      tagList(
        selectInput(inputId = "SELEC_COL_SEPARATE", label = "Selecione a coluna",
                    choices = colnames(reactive_values$data)),
        textInput(inputId = "TEXT_SEPARATE_SEP", label = "Defina um separador",
                  placeholder = "Algo como: ., e, +, -"),
        textInput(inputId = "TEXT_SEPARATE_INTO", label = "Defina as colunas resultantes",
                  placeholder = '"Coluna_1, Coluna_2", ou "Novas Colunas" se você não sabe o total de colunas')
      )
    } else if (selected_function() == "unite"){
      tagList(
        textInput(inputId = "TEXT_UNITE_NEW", label = "Defina o nome da nova coluna"),
        selectInput(inputId = "SELEC_COLS_UNITE", label = "Selecione as colunas para unir",
                    choices = colnames(reactive_values$data), multiple = T),
        textInput(inputId = "TEXT_UNITE_SEP", label = "Defina um separador para os valores",
                  placeholder = "Algo como: e, +, -"),
        checkboxInput(inputId = "CHECK_UNITE_REMOVE", label = "Remover as colunas unidas?",
                      value = T)
      )
    } else if (selected_function() == "mutate"){
      tagList(
        selectInput(inputId = "SELEC_GROUP_BY", label = "Selecione uma coluna para agrupar",
                    multiple = TRUE, choices = colnames(reactive_values$data)),
        textInput(inputId = "TEXT_MUTATE", label = "Nomeie a nova coluna, ou escolha uma coluna existente"),
        selectInput(inputId = "SELEC_MUTATE", label = "Escolha como mudar/criar a coluna",
                    choices = mutate_choices),
        renderUI({
          reactive_values$mutate_type <- input$SELEC_MUTATE

          switch(reactive_values$mutate_type,
                 "Operações numéricas" = textInput(inputId = "TEXT_MUTATE_OPERACOES",
                                                   label = "Defina a equação"),
                 "Operações com funções" = tagList(
                   selectInput(inputId = "SELEC_MUTATE_FUN_COL", label = "Escolha a coluna",
                               choices = colnames(reactive_values$data)),
                   selectInput(inputId = "SELEC_MUTATE_FUN", label = "Escolha a função",
                               choices = c("log", "exp", "mean", "sum", "min", "max", "cumsum"))
                 )
                 # "Conversão de classes" = tagList(
                 #   selectInput(inputId = "SELEC_MUTATE_CLASS_COL", label = "Escolha a coluna",
                 #               choices = colnames(reactive_values$data)),
                 #   selectInput(inputId = "SELEC_MUTATE_CLASS", label = "Escolha a classe",
                 #               choices = c("numeric", "character", "logical", "Date"))
                 # ),
                 # "Somatórios" = tagList(
                 #   selectInput(inputId = "SELEC_MUTATE_SUM",
                 #               label = "Qual tipo de somatório?",
                 #               choices = c("sum - Somatório geral",
                 #                           "cumsum - Somatório acumulado")),
                 #   selectInput(inputId = "SELEC_MUTATE_SUM_COL",
                 #               label = "Escolha a coluna",
                 #               choices = colnames(reactive_values$data))
                 # ),
                 # "'Se, senão' (If, else)" = tagList(
                 #   textInput(inputId = "TEXT_MUTATE_IF", label = "Se"),
                 #   textInput(inputId = "TEXT_MUTATE_IF_TRUE", label = "Então"),
                 #   textInput(inputId = "TEXT_MUTATE_IF_FALSE", label = "Se não, então")
                 # )
          )
        })
      )
    }
  })

  ## INCLUIR NOVAS TABS ----
  add_tab_summ <- function(id){
    tagList(
      selectInput(inputId = paste0("SELEC_COL_SUMM_", id), label = paste("Selecione uma variável para var", id),
                  choices = colnames(reactive_values$data), selected = NULL),
      renderUI({
        selected_column_summ <- rlang::eval_tidy(rlang::parse_expr(paste0("input$SELEC_COL_SUMM_", id)))
        summ_class <- class(reactive_values$data[[selected_column_summ]])

        switch(summ_class,
               "numeric" = selectInput(inputId = paste0("FCT_SUMM_", id),
                                       label = paste("Selecione o tipo de sumarização para var", id),
                                       choices = numeric_summs),
               "integer" = selectInput(inputId = paste0("FCT_SUMM_", id),
                                       label = paste("Selecione o tipo de sumarização para var", id),
                                       choices = numeric_summs),
               "character" = selectInput(inputId = paste0("FCT_SUMM_", id),
                                         label = paste("Selecione o tipo de sumarização para var", id),
                                         choices = "contagem"),
               "factor" = selectInput(inputId = paste0("FCT_SUMM_", id),
                                      label = paste("Selecione o tipo de sumarização para var", id),
                                      choices = "contagem"))
      })
    )
  }

  add_tab_rename <- function(id){
    tagList(
      selectInput(inputId = paste0("SELEC_COL_RENAME_", id), label = "Selecione a coluna",
                  choices = colnames(reactive_values$data)),
      textInput(inputId = paste0("TEXT_RENAME_COL_", id), label = "Renomeie a coluna",
                placeholder = "Escreva aqui")
    )
  }

  observe({
    isolate(input$BTN_ADD_TAB)

    if(selected_function() == "summarise"){
      reactive_values$cont_tabs <- reactive_values$cont_tabs + 1

      insertTab(inputId = "BOX_FUN_INPUTS", target = paste0("Variável ", reactive_values$cont_tabs - 1),
                position = "after", select = TRUE,
                tabPanel(title = paste0("Variável ", reactive_values$cont_tabs), add_tab_summ(reactive_values$cont_tabs)))
    }

    if(selected_function() == "rename"){
      reactive_values$cont_tabs <- reactive_values$cont_tabs + 1

      insertTab(inputId = "BOX_FUN_INPUTS", target = paste0("Variável ", reactive_values$cont_tabs - 1),
                position = "after", select = TRUE,
                tabPanel(title = paste0("Variável ", reactive_values$cont_tabs), add_tab_rename(reactive_values$cont_tabs)))
    }
  }) |>
    bindEvent(input$BTN_ADD_TAB)

  observe({
    isolate(input$BTN_RMV_TAB)

    if(reactive_values$cont_tabs > 1){
      removeTab(inputId = "BOX_FUN_INPUTS", target = paste0("Variável ", reactive_values$cont_tabs))

      reactive_values$cont_tabs <- reactive_values$cont_tabs - 1
    }
  }) |> bindEvent(input$BTN_RMV_TAB)


  ## R CODE ----
  observe({
    if(selected_function() == "select"){
      cols <- input$SELEC_COLS
      cols <- sprintf("%s", paste(sprintf("%s", cols), collapse = ", "))

      reactive_values$code <- paste0(isolate(reactive_values$code), " |>\n select(", cols, ")")
      reactive_values$data <- reactive_values$data |>
        select(input$SELEC_COLS)
    }

    else if(selected_function() == "filter"){
      condition <- logical_condition(input$SELEC_CONDT)
      filtering <- sprintf("%s %s '%s'", input$SELEC_COL_FILTER, condition, input$FILTER_VALUE)
      filter_code <- paste0(isolate(reactive_values$code), " |>\n filter(rlang::eval_tidy(rlang::parse_expr(filtering)))")

      reactive_values$code <- paste0(isolate(reactive_values$code), " |>\n filter(", input$SELEC_COL_FILTER, " ", condition, " '", input$FILTER_VALUE, "')")
      reactive_values$data <- rlang::eval_tidy(rlang::parse_expr(filter_code))
    }

    else if(selected_function() == "summarise"){
      summarise_code <- NULL

      for(i in 1:reactive_values$cont_tabs){
        summarise_col <- rlang::eval_tidy(rlang::parse_expr(paste0("input$SELEC_COL_SUMM_", i)))
        summarise_fct <- rlang::eval_tidy(rlang::parse_expr(paste0("input$FCT_SUMM_", i)))

        summarise_fct <- switch(summarise_fct,
                                "mean" = "mean",
                                "median" = "median",
                                "standard deviation" = "sd",
                                "variance" = "var",
                                "minimum" = "min",
                                "maximum" = "max")

        summarise_new_col <- paste(summarise_col, summarise_fct, sep = "_")

        summarise_act <- paste0(summarise_new_col, " = ", summarise_fct, "(", summarise_col, ")")

        summarise_code <- c(summarise_code, summarise_act)
      }

      if(any(input$SELEC_GROUP_BY %in% colnames(reactive_values$data))){
        group_cols <- input$SELEC_GROUP_BY
        group_cols <- sprintf("%s", paste(sprintf("%s", group_cols), collapse = ", "))

        reactive_values$code <- paste0(isolate(reactive_values$code), " |>\n group_by(", group_cols, ")")
      }

      summarise_code <- paste0(summarise_code, collapse = ",\n          ")
      summarise_code <- paste0("summarise(", summarise_code, ")")
      summarise_code <- paste0(isolate(reactive_values$code), " |>\n ", summarise_code)

      reactive_values$code <- summarise_code
      reactive_values$data <- rlang::eval_tidy(rlang::parse_expr(summarise_code))
    }
    else if (selected_function() == "count"){
      cols <- input$SELEC_COLS_COUNT
      cols <- sprintf("%s", paste(sprintf("%s", cols), collapse = ", "))

      reactive_values$code <- paste0(isolate(reactive_values$code), " |>\n count(", cols, ")")
      reactive_values$data <- reactive_values$data |>
        count(input$SELEC_COLS)
    }
    else if (selected_function() == "arrange"){
      cols <- input$SELEC_COLS_ARRANGE
      cols <- sprintf("%s", paste(sprintf("%s", cols), collapse = ", "))

      reactive_values$code <- paste0(isolate(reactive_values$code), " |>\n arrange(", cols, ")")
      reactive_values$data <- reactive_values$data |>
        arrange(input$SELEC_COLS)
    }
    else if (selected_function() == "rename"){
      rename_code <- NULL

      for(i in 1:reactive_values$cont_tabs){
        rename_old_name <- rlang::eval_tidy(rlang::parse_expr(paste0("input$SELEC_COL_RENAME_", i)))
        rename_new_name <- rlang::eval_tidy(rlang::parse_expr(paste0("input$TEXT_RENAME_COL_", i)))

        rename_code <- paste0(rename_new_name, " = ", rename_old_name)
      }

      rename_code <- paste0(rename_code, collapse = ",\n          ")
      rename_code <- paste0("rename(", rename_code, ")")
      rename_code <- paste0(isolate(reactive_values$code), " |>\n ", rename_code)

      reactive_values$code <- rename_code
      reactive_values$data <- rlang::eval_tidy(rlang::parse_expr(rename_code))
    }
    else if (selected_function() == "separate"){
      col <- input$SELEC_COL_SEPARATE

      col_sep <- input$TEXT_SEPARATE_SEP
      col_sep <- escape_special_chars(col_sep)
      col_sep <- sprintf("'%s'", col_sep)

      # into_cols <- string
      into_cols <- input$TEXT_SEPARATE_INTO

      if(stringr::str_to_upper(into_cols) == "NOVAS COLUNAS"){
        tmp_sep <- stringr::str_replace(col_sep, pattern = "\\\\\\\\", replacement = "\\\\")
        tmp_sep <- stringr::str_replace_all(tmp_sep, pattern = "'", replacement = "")

        nmax <- max(stringr::str_count(purrr::pluck(reactive_values$data, col),
                                       pattern = tmp_sep)) + 1

        into_cols <- paste0("col_", seq_len(nmax))
        into_cols <- paste0("c(", paste0(sprintf("'%s'", into_cols), collapse = ", "), ")")

        separate_code <- paste0(isolate(reactive_values$code), " |>\n separate(col = ", col, ", into = ", into_cols, ", sep = ", col_sep, ")")

        reactive_values$code <- separate_code
        reactive_values$data <- rlang::eval_tidy(rlang::parse_expr(separate_code))
      } else{
        into_cols <- stringr::str_replace_all(string = into_cols, pattern = '"', replacement = "'")
        into_cols <- stringr::str_replace_all(string = into_cols, pattern = "'", replacement = "")
        into_cols <- strsplit(into_cols, split = ",") |> unlist() |> stringr::str_trim()
        into_cols <- paste0("c(", paste0(sprintf("'%s'", into_cols), collapse = ", "), ")")

        separate_code <- paste0(isolate(reactive_values$code), " |>\n separate(col = ", col, ", into = ", into_cols, ", sep = ", col_sep, ")")

        reactive_values$code <- separate_code
        reactive_values$data <- rlang::eval_tidy(rlang::parse_expr(separate_code))
      }
    }
    else if (selected_function() == "unite"){
      unite_new <- input$TEXT_UNITE_NEW

      unite_sep <- input$TEXT_UNITE_SEP
      unite_sep <- sprintf("'%s'", unite_sep)

      unite_cols <- input$SELEC_COLS_UNITE
      unite_cols <- paste0(unite_cols, collapse = ", ")

      unite_remove <- input$CHECK_UNITE_REMOVE

      unite_code <- paste0(isolate(reactive_values$code), " |>\n unite(col = ", unite_new, ", sep = ", unite_sep, ", remove = ", unite_remove, ", ", unite_cols, ")")

      reactive_values$code <- unite_code
      reactive_values$data <- rlang::eval_tidy(rlang::parse_expr(unite_code))
    }
    else if (selected_function() == "mutate"){
      mutate_code <- NULL

      mutate_col <- input$TEXT_MUTATE
      mutate_code <- paste0("mutate(", mutate_col, " = ")

      mutate_code <- switch(reactive_values$mutate_type,
                            "Operações numéricas" = paste0(mutate_code, input$TEXT_MUTATE_OPERACOES, ")"),
                            "Operações com funções" = paste0(mutate_code, input$SELEC_MUTATE_FUN, "(",
                                                             input$SELEC_MUTATE_FUN_COL, "))")#,
                            # "Somatórios" = paste0(mutate_code, gsub("\\s*-.*", "", input$SELEC_MUTATE_SUM), "(",
                            #                       input$SELEC_MUTATE_SUM_COL, "))"
                            #
                            # ),
                            # "'Se, senão' (If, else)" = paste0(mutate_code, "if_else(condition = ",
                            #                                   input$TEXT_MUTATE_IF, ", true = '",
                            #                                   input$TEXT_MUTATE_IF_TRUE, "', false = '",
                            #                                   input$TEXT_MUTATE_IF_FALSE, "'))")
      )

      if(any(input$SELEC_GROUP_BY %in% colnames(reactive_values$data))){
        group_cols <- input$SELEC_GROUP_BY
        group_cols <- sprintf("%s", paste(sprintf("%s", group_cols), collapse = ", "))

        reactive_values$code <- paste0(isolate(reactive_values$code), " |>\n group_by(", group_cols, ")")
      }

      mutate_code <- paste0(isolate(reactive_values$code), " |>\n ", mutate_code)

      reactive_values$code <- mutate_code
      # reactive_values$data <- rlang::eval_tidy(rlang::parse_expr(mutate_code))
    }
  }) |>
    bindEvent(input$EXEC_FCT)

  # output$DATA <- function(){
  #   rlang::eval_tidy(rlang::parse_expr(reactive_values$code)) |>
  #       # DT::datatable(escape = F, rownames = F, class = "cell-border compact", selection = "none",
  #       #               options = list(ordering = T, autowidth = F, scrollX = TRUE, scrollY = 390, paging = FALSE,
  #       #                              language = list(lengthMenu = "_MENU_"), lengthChange = FALSE, dom = "<<\"datatables-scroll\"t>>",
  #       #                              columnDefs = list(list(className = "dt-center", targets = "_all"))
  #       #                              ))
  #     kableExtra::kbl(escape = T) |>
  #     kableExtra::kable_styling(full_width = F) |>
  #     kableExtra::row_spec(0, bold = T) |>
  #     kableExtra::scroll_box(height = "450px", width = "490px")
  #   }

  output$DATA <- reactable::renderReactable({
    rlang::eval_tidy(rlang::parse_expr(reactive_values$code)) |>
      reactable::reactable(bordered = T, striped = T, outlined = T,
                           filterable = F, sortable = F)
  })

  output$CODE <- renderPrint({
    reactive_values$code |>
      cat()
  })

  output$BTN_CLIPBOARD <- renderUI({
    rclipButton(
      "BTN_CLIP",
      "Copy to clipboard",
      clipText = reactive_values$code,
      icon = icon("clipboard")
    )
  })

  output$DEBUG <- renderPrint({
    print(str(reactiveValuesToList(reactive_values)))
  })
}

shinyApp(ui, server)
