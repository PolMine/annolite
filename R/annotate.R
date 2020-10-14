#' Call Leightweight Annotation Widget.
#' 
#' @param input Either a \code{annotatordata} object or an object that can be
#'   coerced to \code{annotatordata} using the \code{as.annotatordata} method.
#' @param width The width of the annotator htmlwidget.
#' @param height The height of the annotator htmlwidget.
#' @param dialog Specification of the dialog box.
#' @param file If a \code{character} vector, a filename to save table with
#'   annotations to disk whenever a new annotation is added. If the filename
#'   ends with ".rds", a RDS file is saved. In all other cases, a csv file
#'   is generated.
#' @param ... Further arguments passed into call of \code{as.annotatordata} if
#'   argument \code{input} is not an \code{annotatordata} class object.
#' @return A \code{data.frame} with annotations is returned invisibly.
#' @importFrom miniUI miniPage miniContentPanel gadgetTitleBar miniButtonBlock
#'   miniTabstripPanel miniTabPanel
#' @importFrom shiny tags runGadget paneViewer textAreaInput observeEvent
#'   stopApp reactiveValues icon observe
#' @importFrom shinyjs useShinyjs extendShinyjs js
#' @importFrom shinyWidgets prettyRadioButtons
#' @importFrom methods is
#' @importFrom DT dataTableOutput renderDataTable datatable
#' @export annotate
#' @examples
#' library(polmineR)
#' use("polmineR")
#' P <- partition("GERMAPARLMINI", speaker = "Volker Kauder", date = "2009-11-10")
#' if (interactive()) Y <- annotate(P, headline = "Volker Kauder (CDU)")
#' 
#' D <- as.annotatordata(P, headline = "Volker Kauder (CDU)")
#' D$annotations <- sample_annotation
#' if (interactive()) Y <- annotate(D)
annotate <- function(input, width = NULL, height = NULL, dialog = list(choices = dialog_radio_buttons(keep = "yellow", drop = "orange")), file = NULL, ...) { 
  
  if (!is.annotatordata(input)) input <- as.annotatordata(input, ...)
  
  TXT <- annotator(input, width = width, height = height, dialog = dialog, box = FALSE)
  
  values <- reactiveValues()

  ui <- miniPage(
    gadgetTitleBar(title = "Annotation Gadget"),
    miniTabstripPanel(
      miniTabPanel(
        "Text", icon = icon("file"),
        miniContentPanel( annotatorOutput("annotator"))
      ),
      miniTabPanel(
        "Annotations", icon = icon("table"),
        miniContentPanel( DT::dataTableOutput('annotations', height = "100%") )
      )
    )
    
  )
  
  server <- function(input, output, session) {
    
    output$annotator <- renderAnnotator(TXT)
    
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
