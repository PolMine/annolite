#' @importFrom miniUI miniPage miniContentPanel gadgetTitleBar miniButtonBlock
#' @importFrom shiny tags runGadget paneViewer textAreaInput observeEvent stopApp
#' @importFrom shinyjs useShinyjs extendShinyjs js
#' @importFrom shinyWidgets prettyRadioButtons
#' @importFrom methods is
annotate <- function(input, freetext = FALSE, codes = c(great = "lightgreen", positive = "green", neutral = "darkgrey", negative = "red", obnoxious = "darkred")) { 
  
  message(Sys.time(), " generating fulltext")
  TXT <- fulltext(input)
  
  ranges <- data.frame(code = character(), cpos_left = integer(), cpos_right = integer())
  
  jsCode <- sprintf(
    'shinyjs.change_color = function(new_color) { window.annotation_color = new_color; };',
    unname(codes)[[1]]
  )

  ui <- miniPage(
    
    useShinyjs(),
    extendShinyjs(text = jsCode),
    
    gadgetTitleBar(title = "Annotation Gadget"),
    miniContentPanel( fulltextOutput("fulltext")),
    miniButtonBlock(
      prettyRadioButtons(
        inputId = "color", label = NULL,
        choiceNames = lapply(1L:length(codes), function(i) tags$span(style = sprintf("padding: 0.25em; border-radius: 5px; border: 1px solid #aaa; font-weight: bold; color: white; background-color:%s;", codes[[i]]), sprintf("%s", names(codes)[[i]]))),
        choiceValues = unname(codes),
        inline = TRUE, fill = TRUE, bigger = TRUE, outline = FALSE, animation = "pulse"
      )
    ),
    if (freetext) miniButtonBlock(textAreaInput("memo", label = NULL, width = "100%"), border = 0) else NULL
  )
  
  server <- function(input, output, session) {
    

    output$fulltext <- renderFulltext(TXT)
    
    observeEvent(
      input$range,
      {
        ranges <<- rbind(
          ranges,
          data.frame(
            code = names(codes)[which(unname(codes) == input$color)],
            cpos_left = input$range[1],
            cpos_right = input$range[2]
          )
        )
      }
    )
    
    observeEvent(input$color, js$change_color(input$color))
    
    observeEvent(input$done, stopApp(ranges))
  }

  runGadget(ui, server, viewer = paneViewer(300))
}
