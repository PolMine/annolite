#' Shiny Gadget for Text Annotation.
#' 
#' Calling the method `annotate()` on an object that is either a `fulltexttable`
#' or that can be transformed to a `fulltexttable` (using the method
#' `fulltexttable()`) will launch a Shiny Widget as a leightweight text
#' annotation tool. The HTML widget `annolite` is the core of the gadget. It
#' provides the essential functionality for highlighter-and-pencil-style
#' annotation. Wrapping the *annolite*  HTML wideget in a Shiny Gadget
#' facilitates the implementation of a pure R workflow for generating and
#' procesing text annotations.
#' 
#' @param file If a `character` vector, a filename that is used to save table
#'   with annotations to disk whenever a new annotation is added. If the
#'   filename ends with ".rds", a RDS file is saved. In all other cases, a csv
#'   file is generated.  If the parent directory of the file does not exists,
#'   `annotate()` will abort issuing an error message. Note that existing files
#'   will be overwritten. If argument is `NULL` (default), no file with
#'   annotations will be generated an upated.
#' @param ... Further arguments passed into call of `fulltexttable()`.
#' @return A `data.frame` with annotations (class `annotationstable`) is
#'   returned invisibly.
#' @importFrom miniUI miniPage miniContentPanel gadgetTitleBar miniButtonBlock
#'   miniTabstripPanel miniTabPanel
#' @importFrom shiny tags runGadget paneViewer textAreaInput observeEvent
#'   stopApp reactiveValues icon observe
#' @importFrom methods is
#' @importFrom DT dataTableOutput renderDataTable datatable
#' @importFrom utils write.table
#' @export annotate
#' @inheritParams annolite
#' @examples
#' library(polmineR)
#' use("polmineR")
#' P <- partition("GERMAPARLMINI", speaker = "Volker Kauder", date = "2009-11-10")
#' if (interactive()) Y <- annotate(P)
#' if (interactive()) Y <- annotate(D, annotations = sample_annotation)
annotate <- function(x, annotations = annotationstable(), width = NULL, height = NULL, buttons = list(keep = "yellow", drop = "orange"), file = NULL, ...) { 
  
  if (isFALSE(is.null(file))){
    if (isFALSE(dir.exists(dirname(file))))
      stop(sprintf("Cannot use file '%s' to store annotations: Directory '%s' does not exist.", file, dirname(file)))
  } 
  
  x <- fulltexttable(x, ...)
  TXT <- annolite(x = x, annotations = annotations, width = width, height = height, buttons = buttons, box = FALSE)
  values <- reactiveValues()

  ui <- miniPage(
    gadgetTitleBar(title = "Annotation Gadget"),
    miniTabstripPanel(
      miniTabPanel(
        "Text", icon = icon("file"),
        miniContentPanel( annoliteOutput("annolite"))
      ),
      miniTabPanel(
        "Annotations", icon = icon("table"),
        miniContentPanel( DT::dataTableOutput('annotations', height = "100%") )
      )
    )
    
  )
  
  server <- function(input, output, session) {
    
    output$annolite <- renderAnnolite(TXT)
    
    observeEvent(
      input$annotations_created,
      {
        values[["annotations"]] <- data.frame(lapply(input$annotations_table, unlist))
        if (isFALSE(is.null(file))){
          if (endsWith(file, ".rds")){
            saveRDS(object = values[["annotations"]], file = file)
          } else {
            write.table(x = values[["annotations"]], file = file, append = FALSE, quote = TRUE, sep = ", ")
          }
        }
      }
    )
    
    observeEvent(input$done, stopApp(invisible(values[["annotations"]])))
  }

  runGadget(ui, server, viewer = paneViewer())
}
