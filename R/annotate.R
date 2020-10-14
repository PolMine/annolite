#' Leightweight Annotation Widget.
#' 
#' @param input A list of data.frames according to the requirements of fulltext
#'   input.
#' @param width The width of the fulltext htmlwidget.
#' @param height The height of the fulltext htmlwidget.
#' @param dialog Specification of the dialog box.
#' @importFrom miniUI miniPage miniContentPanel gadgetTitleBar miniButtonBlock miniTabstripPanel miniTabPanel
#' @importFrom shiny tags runGadget paneViewer textAreaInput observeEvent stopApp reactiveValues icon observe
#' @importFrom shinyjs useShinyjs extendShinyjs js
#' @importFrom shinyWidgets prettyRadioButtons
#' @importFrom methods is
#' @importFrom DT dataTableOutput renderDataTable datatable
#' @export annotate
#' @examples
#' library(polmineR)
#' use("polmineR")
#' P <- partition("GERMAPARLMINI", speaker = "Volker Kauder", date = "2009-11-10")
#' D <- as.fulltextdata(P, headline = "Volker Kauder (CDU)")
#' D[["annotations"]] <- sample_annotation
#' if (interactive()) Y <- annotate(D)
annotate <- function(input, width = NULL, height = NULL, dialog = list(choices = dialog_radio_buttons(keep = "yellow", drop = "orange"))) { 
  
  TXT <- fulltext(input, width = width, height = height, dialog = dialog, box = FALSE)
  
  values <- reactiveValues()

  ui <- miniPage(
    gadgetTitleBar(title = "Annotation Gadget"),
    miniTabstripPanel(
      miniTabPanel(
        "Text", icon = icon("file"),
        miniContentPanel( fulltextOutput("fulltext"))
      ),
      miniTabPanel(
        "Annotations", icon = icon("table"),
        miniContentPanel( DT::dataTableOutput('annotations', height = "100%") )
      )
    )
    
  )
  
  server <- function(input, output, session) {
    

    output$fulltext <- renderFulltext(TXT)
    
    observeEvent(
      input$annotations_created,
      {
        values[["annotations"]] <- data.frame(lapply(input$annotations_table, unlist))
      }
    )
    
    observeEvent(input$done, stopApp(values[["annotations"]]))
  }

  runGadget(ui, server, viewer = paneViewer())
}
