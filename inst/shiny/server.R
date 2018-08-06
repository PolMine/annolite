shinyServer(function(input, output, session){
  
  P <- reactive(get(input$object, env = .GlobalEnv)$partition)
  
  fulltext <- reactive({
    if (is.null(P()) == FALSE){
      gsub("^.*?<body>(.*?)</body>.*?$", "\\1", polmineR::html(P(), meta = c("text_date", "text_name"), cpos = TRUE))
    }
    
  })

  observeEvent(
    fulltext(),
    {
      js$clear()
      if (length(get(input$object, env = .GlobalEnv)$annotations) > 0){
        print("there are annotations")
        jsonChar <- as.character(jsonlite::toJSON(get(input$object, env = .GlobalEnv)$annotations))
        js$restoreAnnotations(jsonChar)
      }
    }
  )
  
  observeEvent(
    input$restore,
    {
      jsonChar <- as.character(jsonlite::toJSON(get(input$object, env = .GlobalEnv)$annotations))
      js$restoreAnnotations(jsonChar)
  })
  
  
  output$fulltext <- renderUI({ fulltext() })
  
  observe({
    input$annotationCreated
    if (length(input$annotationCreated > 0)){
      print("... adding annotation")
      annotationList <- jsonlite::fromJSON(input$annotationCreated)
      get(input$object, env = .GlobalEnv)$addAnnotation(
        id = annotationList$id,
        annotation = annotationList
        )
    }
  })
  
  observe({
    input$annotationDeleted
    if (length(input$annotationDeleted) > 0){
      print("... removin annotation")
      get(input$object, env = .GlobalEnv)$deleteAnnotation(input$annotationDeleted)
    }
  })
  
  observe({
    input$annotationUpdated
    if (length(input$annotationUpdated) > 0){
      print("... updating annotation")
      annotationList <- jsonlite::fromJSON(input$annotationUpdated)
      get(input$object, env = .GlobalEnv)$addAnnotation(
        id = annotationList$id,
        annotation = annotationList
      )
    }
  })
})