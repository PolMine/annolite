#' Instantiate annolite htmlwidget.
#' 
#' @param x A `fulltexttable`.
#' @param annotations A `annotationstable`.
#' @param width The width of the widget.
#' @param height The height of the widget.
#' @param dialog The dialog.
#' @param box Logical, whether to put text into a box.
#' @param group crosstalk group
#' @param layout Relevant for crosstalk mode
#' @param crosstalk \code{logical}, whether to use crosstalk
#' @param ... Further arguments
#' @importFrom htmlwidgets createWidget sizingPolicy
#' @importFrom crosstalk crosstalkLibs is.SharedData bscols
#' @importFrom utils packageVersion
#' @export annolite
#' @aliases annolite-package annolite
#' @docType package
#' @name annolite
#' @rdname annolite
#' @examples 
#' library(polmineR)
#' sc <- corpus("GERMAPARLMINI") %>%
#'   subset(speaker == "Volker Kauder" & date == "2009-11-10")
#' tab <- fulltexttable(sc)
#' y <- annolite(
#'   x = tab, annotations = annotationstable(),
#'   width = "100%",
#'   dialog = list(choices = dialog_radio_buttons(keep = "yellow", drop = "orange"))
#' )
#' @author Andreas Blaette
setGeneric("annolite", function(x, ...) standardGeneric("annolite"))

setOldClass("fulltexttable")

#' @rdname annolite
setMethod("annolite", "fulltexttable", function(x, annotations = annotationstable(), dialog = NULL, width = "100%", height = NULL,  box = TRUE, crosstalk = FALSE, layout = "filter", group = "fulltext") {
  
  if (length(unique(x[["name"]])) == 1L){
    y <- createWidget(
      "annolite",
      package = "annolite",
      x = list(
        data = list(fulltext = htmlize(x), annotations = annotations),
        settings = list(
          annotationMode = TRUE,
          crosstalk = crosstalk,
          crosstalk_key = NULL,
          crosstalk_group = group,
          dialog = if (is.null(dialog)) FALSE else TRUE,
          box = box,
          codeSelection = if (!is.null(dialog)) if ("choices" %in% names(dialog)) dialog[["choices"]],
          callbackFunction = if (!is.null(dialog)) if ("callback" %in% names(dialog)) htmlwidgets::JS(dialog[["callback"]])
        )
      ),
      width = width,
      height = height,
      dependencies = list(
        htmltools::htmlDependency(
          name = "crosstalk", 
          version = packageVersion("crosstalk"),
          package = "crosstalk",
          src = "www",
          script = "js/crosstalk.min.js",
          stylesheet = "css/crosstalk.css"
        )
      ),
      sizingPolicy(
        browser.fill = TRUE,
        viewer.defaultHeight = 800L,
        browser.defaultHeight = 800L,
        viewer.fill = TRUE,
        knitr.figure = FALSE,
        knitr.defaultWidth = 800L,
        knitr.defaultHeight = 400L
      )
    )
  } else {
    x[["style"]] <- rep("display:none", times = nrow(x))
    x_sd <- crosstalk::SharedData$new(x, ~name, group = group) 
    if (layout == "filter"){
      y <- bscols(
        widths = c(3,9), device = "lg",
        crosstalk::filter_select(id = "select_text", label = "Selection", sharedData = x_sd, group = ~name, multiple = FALSE),
        htmlwidgets::createWidget(
          "annolite",
          package = "annolite",
          x = list(
            data = list(fulltext = htmlize(x), annotations = annotations),
            settings = list(
              annotationMode = FALSE,
              crosstalk = TRUE,
              box = box,
              crosstalk_key = "name",
              crosstalk_group = group
            )
          ),
          width = width, 
          height = height,
          dependencies = crosstalk::crosstalkLibs()
        )
      )
    } else {
      doc_datatable_sd <- DT::datatable(
        crosstalk::SharedData$new(data.frame(document_id = x[["name"]]), ~document_id, group = group),
        options = list(lengthChange = TRUE, pageLength = 8L, pagingType = "simple", dom = "tp"),
        rownames = NULL, width = "100%", selection = "single"
      )
      
      y <- bscols(
        widths = c(4,8),
        doc_datatable_sd,
        annolite(x_sd, annotations = annotations, width = width, height = height, box = box, crosstalk = TRUE)
      )
    }
  }
  y
})

setOldClass("SharedData")

#' @rdname annolite
#' @exportMethod annolite
setMethod("annolite", "SharedData", function(x, annotations = NULL, width = "100%", height = NULL, box = TRUE, group = x$groupName(), crosstalk = TRUE) {
  annolite(
    x = x$origData(),
    annotations = annotations,
    width = width, height = height, box = box,
    group = group, crosstalk = TRUE
  )
})


#' Render annolite htmlwidget in shiny apps.
#' 
#' @param outputId Output variable to read the value from.
#' @param width The width of the widget.
#' @param height The height of the widget.
#' @param expr An expression (...).
#' @param env The environment in which to evaluate expr.
#' @param quoted Is expr a quoted expression (with quote())? This is useful if
#'   you want to save an expression in a variable.
#' @export annoliteOutput
#' @importFrom htmlwidgets shinyWidgetOutput
#' @rdname shiny
annoliteOutput <- function(outputId, width = "100%", height = "100%") {
  shinyWidgetOutput(outputId, "annolite", width, height, package = "annolite")
}
#' @export renderAnnolite
#' @importFrom htmlwidgets shinyRenderWidget
#' @rdname shiny
renderAnnolite <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  shinyRenderWidget(expr, annoliteOutput, env, quoted = TRUE)
}


#' @rdname annolite
"sample_annotation"

#' @rdname annolite
"emma_chapters_tokenized"

#' @rdname annolite
"secretary_general_2000"

#' @rdname annolite
"unga_migrationspeeches_fulltext"

#' @rdname annolite
"unga_migrationspeeches_anntationstable"
