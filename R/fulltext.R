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
fulltext <- function(data = list(token = LETTERS[1:10], cpos = 1:10), width = NULL, height = NULL) {
  createWidget(
    "fulltext",
    x = list(data = data, settings = list()),
    width = width,
    height = height,
    sizingPolicy(knitr.figure = FALSE,
                 browser.fill = TRUE,
                 knitr.defaultWidth = "100%",
                 knitr.defaultHeight = 300)
    )
}
