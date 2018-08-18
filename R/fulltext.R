#' Fulltext output.
#' 
#' @param data The data that is passed to the JavaScript that generates the output. Expected to be
#' a list of lists that provide data on sections of text. Each of the sub-lists is to be a named
#' list of a character vector with the HTML element the section will be wrapped into, and 
#' a \code{data.frame} (or a list) with a column "token", and a column "cpos".
#' @param width The width of the widget.
#' @param height The height of the widget.
#' @importFrom htmlwidgets createWidget sizingPolicy
#' @export fulltext
fulltext <- function(data = list(token = LETTERS[1:10], cpos = 1:10), width = NULL, height = NULL, codes = c(keep = "green", drop = "orange", reconsider = "grey")) {
  
  callbackFunction <- c(
    "function (result) {",
      "var code_selected = $('#selection input:radio:checked').val();",
      "for (var cpos = window.cpos_left; cpos <= window.cpos_right; cpos++) {",
        "var spanEl = document.getElementById(cpos.toString());",
        "spanEl.style.backgroundColor = code_selected;",
      "}",
      "Shiny.onInputChange('code', code_selected);",
      "Shiny.onInputChange('annotation', result);",
      "Shiny.onInputChange('region', [cpos_left, cpos_right]);",
      "console.log(window.getSelection().toString());",
      "Shiny.onInputChange('text', window.highlighted_text);",
      "",
      "if (window.getSelection().empty) {  // Chrome",
        "window.getSelection().empty();",
      "} else if (window.getSelection().removeAllRanges) {  // Firefox",
        "window.getSelection().removeAllRanges();",
      "}",
    "}"
  )
  
  createWidget(
    "fulltext",
    x = list(
      data = data,
      settings = list(
        codeSelection = paste(
          c('Add Annotation',
          '<hr/>',
          '<div id="selection" class="btn-group" data-toggle="buttons">',
          sprintf(
            '<label class="radio-inline"><input type="radio" name="optradio" checked value="%s">%s</label>',
            unname(codes), names(codes)
          ),
          '</div>'
          ), collapse = ""
        ),
        callbackFunction = htmlwidgets::JS(callbackFunction)
      )
    ),
    width = width,
    height = height,
    sizingPolicy(browser.fill = TRUE,
                 viewer.defaultHeight = 800L,
                 browser.defaultHeight = 800L,
                 viewer.fill = TRUE,
                 knitr.figure = FALSE,
                 knitr.defaultWidth = NULL,
                 knitr.defaultHeight = 300
                 )
    )
}


#' Render and show fulltext output in shiny apps.
#' 
#' @param outputId Output variable to read the value from.
#' @param width The width of the widget.
#' @param height The height of the widget.
#' @param expr An expression (...).
#' @param env The environment in which to evaluate expr.
#' @param quoted Is expr a quoted expression (with quote())? This is useful if
#'   you want to save an expression in a variable.
#' @export fulltextOutput
#' @importFrom htmlwidgets shinyWidgetOutput
#' @rdname shiny
fulltextOutput <- function(outputId, width = "100%", height = "100%") {
  shinyWidgetOutput(outputId, "fulltext", width, height, package = "annolite")
}
#' @export renderFulltext
#' @importFrom htmlwidgets shinyRenderWidget
#' @rdname shiny
renderFulltext <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  shinyRenderWidget(expr, fulltextOutput, env, quoted = TRUE)
}