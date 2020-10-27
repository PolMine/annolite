#' Call Leightweight Annotation Widget.
#' 
#' @param file If a \code{character} vector, a filename to save table with
#'   annotations to disk whenever a new annotation is added. If the filename
#'   ends with ".rds", a RDS file is saved. In all other cases, a csv file
#'   is generated.
#' @param ... Further arguments passed into call of \code{fulltexttable}.
#' @return A \code{data.frame} with annotations is returned invisibly.
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
