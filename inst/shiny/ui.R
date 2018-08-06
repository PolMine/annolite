annotatorObjects <- polmineR::getObjects(class = 'Annotator', envir = .GlobalEnv)

shinyUI(fluidPage(
  useShinyjs(),
  tags$head(tags$script(src = "jquery.min.js")),
  tags$head(tags$script(src = "annotator-full.min.js")),
  includeCSS(system.file("js", "annotator.min.css", package = "polmineR.anno")),
  tags$head(tags$script(src = "annotator.offline.min.js")),
  tags$head(tags$script(src = "annotator.plugin.polmine.js")),
  tags$head(tags$script(src = "tags-annotator.min.js")),
  includeCSS(system.file("js", "tags-annotator.min.css", package="polmineR.anno")),
  
  
  extendShinyjs(script="/Users/blaette/Lab/gitlab/polmineR.anno/inst/shiny/www/shinyjs.interface.js"),
  
  sidebarLayout(
    sidebarPanel(
      selectInput("object", "object", choices = annotatorObjects),
      actionButton("restore", "restore")
    ),
      mainPanel(
        tabsetPanel(
          id = "tabs",
          tabPanel("fulltext", id = "fulltext", uiOutput("fulltext")),
          tabPanel("table", id = "table", dataTableOutput("table"))
        )
      )
  ),
  
  tags$script("var content = $('body').annotator();"),
  tags$script("content.annotator('addPlugin', 'Offline');"),
  tags$script("content.annotator('addPlugin', 'StoreLogger');"),
  tags$script("var optionstags = {tag:'imagery:red,parallelism:blue,sound:green,anaphora:orange'};"),
  tags$script("console.log(optionstags);"),
  tags$script("content.annotator('addPlugin','HighlightTags', optionstags);")
  # tags$script("content.annotator('addPlugin', 'Tags');")
))