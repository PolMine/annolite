#' Annotator
#' 
#' object for annotation
#' 
#' @import R6
#' @field partition a partition object
#' @field type the partition type (e.g. "plpr")
#' @field annotations a JSON string
#' @field filename XXX
#' @field cpos a data.table
#' @section Methods:
#' \describe{
#'   \item{\code{initialize(partition = NULL, filename = NULL)}}{
#'     if partition is NULL, and filename is provided, restore Annotator-object
#'     }
#'   \item{\code{addAnnotation(id, annotation)}}{add an annotation}
#'   \item{\code{updateAnnotation(id, annotation)}}{update an annotation}
#'   \item{\code{deleteAnnotation(id)}}{delete an annotation}
#' }
#' @examples 
#' \dontrun{
#' library(polmineR)
#' library(shiny)
#' library(shinyjs)
#' library(R6)
#' options("polmineR.annoDir" = "/Users/blaette/Lab/tmp/anno")
#' options("shiny.launch.browser" = browseURL)
#' options("browser" = "/Applications/Google\\ Chrome.app/Contents/MacOS/Google\\ Chrome")
#' 
#' filenames <- list.files(getOption("polmineR.annoDir"), full.names = T, patter = "^.*\\.RData$")
#' foo1 <- Annotator$new(filename = "gabriel.json", type = "plpr")
#' foo1 <- Annotator$new(partition = readRDS(filenames[1]), filename = "gabriel.json")
#' foo2 <- Annotator$new(partition = readRDS(filenames[2]), filename = "kauder.json")
#' foo3 <- Annotator$new(partition = readRDS(filenames[3]), filename = "merkel.json")
#' runApp("/Users/blaette/Lab/gitlab/polmineR.anno/inst/shiny")
#' }
#' @export Annotator
Annotator <- R6Class(
  
  "Annotator",
  
  public = list(
    
    # fields 
    
    partition = NULL, # a partition object
    
    annotations = NULL,
    
    type = NULL,
    
    filename = NULL,
    
    cpos = NULL,
    
    # methods
    
    initialize = function(partition = NULL, filename = NULL, type = NULL){
      self$type <- type
      if (is.null(partition) == FALSE){
        stopifnot("partition" %in% is(partition)) # ensure that a partition is provided
        self$partition <- partition
        if (is.null(filename)){
          if (name(self$partition) == ""){
            warning("partition is not named, cannot create filename")
          } else {
            self$filename <- paste(name(self$partition), "RData", sep = ".")
          }
        } else {
          self$filename <- filename
        }
      } else if (is.null(partition) && !is.null(filename)){
        self$filename <- filename
        if (file.exists(file.path(getOption("polmineR.annoDir"), filename))){
          self$restore()
        }
      }
      
    },
    
    addAnnotation = function(id, annotation) self$annotations[[id]] <- annotation,
    
    deleteAnnotation = function(id) self$annotations[[id]] <- NULL,
    
    updateAnnotation = function(id, annotation) self$annotations[[id]] <- annotation,
      
    as.Annotations = function(){
        DT <- data.table(
          cpos_left = sapply(self$annotations, function(x) x$cpos_left),
          cpos_right = sapply(self$annotations, function(x) x$cpos_right),
          text = sapply(self$annotations, function(x) x$text),
          quote = sapply(self$annotations, function(x) x$quote)
        )
        new("Annotations", cpos = DT, corpus = self$corpus, encoding = self$encoding)
    },
    
    store = function(){
      self$partition@annotations <- self$annotations
      cat(
        as.character(as(self$partition, "json")),
        file = file.path(getOption("polmineR.annoDir"), self$filename)
      )
      self$partition@annotations <- list()
    },
    
    restore = function(){
      jsonChar <- paste(
        scan(
          file = file.path(getOption("polmineR.annoDir"), self$filename),
          what = "character", quiet = TRUE
        )
        , collapse = "", sep = ""
      )
      self$partition <- NULL # it is necessary, no idea why ...
      self$partition <- as(
        jsonPartition <- jsonlite::toJSON(jsonlite::fromJSON(jsonChar)),
        "partition"
      )
      if (!is.null(self$type)){
        self$partition@stat <- data.table() # not nice
        self$partition <- as(self$partition, paste(self$type, "Partition", sep = ""))
      }
      self$annotations <- self$partition@annotations
    },
    
    shiny = function(){
      runApp("/Users/blaette/Lab/gitlab/polmineR.anno/inst/shiny")
    }
  ),
  lock_class = FALSE
)



AnnotatorBundle <- R6Class(
  
  "AnnotatorBundle",
  
  public = list(
    
    objects = NULL,
    
    initialize = function(bundle = NULL, type = NULL){
      if (!is.null(bundle)){
        self$objects <- lapply(bundle, function(x) Annotator$new(partition = x, type = type))
      }
    }
  )
)