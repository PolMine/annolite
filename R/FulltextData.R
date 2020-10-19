#' Create and Manage Data for fulltext annotation und display widget.
#' 
#' @param input An object that can be turned into a fulltexttable using \code{as.fulltexttable}.
#' @param annotations A \code{data.frame} that needs to have columns "color",
#'   "start" and "end".
#' @param column The column the examine.
#' @param name New name to assign.
#' @param regex A regular expression to detect whether a tag should be changed.
#' @param old The old tag.
#' @param value Visibility status to assign.
#' @param new The new tag.
#' @param tooltips A named list or character vector with the tooltips to be
#'   displayed. The names of the list/vector are expected to be tokens.
#' @param ... Further arguments.
#' 
#' @field data A fulltexttable.
#' 
#' @export FulltextData
#' @rdname FulltextData
#' @name FulltextData
#' @examples 
#' library(polmineR)
#' k <- corpus("GERMAPARLMINI") %>%
#'   subset(speaker == "Volker Kauder") %>%
#'   subset(date == "2009-11-10")
#'   
#' F <- FulltextData$new(k, headline = "Volker Kauder (CDU)", display = "block")
#' F$highlight(yellow = "Opposition")
#' F$tooltips(tooltips = list(Opposition = "A", Regierung = "B"))
FulltextData <- R6::R6Class(
  
  classname = "FulltextData",
  
  public = list(
    
    data = NULL, # a data.frame

    #' @description 
    #' Initialize a new instance of class \code{CorpusData}.
    #' @return A class \code{CorpusData} object.
    initialize = function(input, ...){
      if (!missing(input)){
        self$data = as.fulltexttable(input, ...)
      }
    },
    
    #' @description
    #' Highlight tokens in fulltexttable
    #' @return The \code{FulltextData} object is returned invisibly.
    highlight = function(annotations = NULL, ...){
      scheme <- list(...)
      if (!is.null(annotations)){
        for (i in 1L:nrow(annotations)){
          for (cpos in annotations[i, "start"]:annotations[i, "end"]){
            j <- which(self$data[["id"]] == cpos)
            self$data[j, "tag_before"] <- sprintf("%s<span style='background-color:%s'>", self$data[j, "tag_before"], annotations[i, "color"])
            self$data[j, "tag_after"] <- sprintf("</span>%s", self$data[j, "tag_after"])
          }
        }
      }
      
      for (color in names(scheme)){
        i <- unique(unlist(lapply(scheme[[color]], function(x) which(self$data[["token"]] == x))))
        self$data[i, "tag_before"] <- sprintf("%s<span style='background-color:%s'>", self$data[i, "tag_before"], color)
        self$data[i, "tag_after"] <- sprintf("</span>%s", self$data[i, "tag_after"])
      }
      invisible(self)
    },
    
    #' @description 
    #' Assign new name
    rename = function(name){
      self$data <- as.data.frame(self$data)
      i <- grep("name='.*?'", self$data[["tag_before"]])
      self$data[i, "tag_before"] <- gsub("name='.*?'", sprintf("name='%s'", name), self$data[i,"tag_before"])
      invisible(self)
    }, 
    
    #' @description 
    #' Get name(s).
    get_name = function(){
      i <- grep("name='.*?'", self$data[["tag_before"]])
      names <- gsub("^.*name='(.*?)'.*$", "\\1", self$data[i,"tag_before"])
      unique(names)
    },
    
    #' @description 
    #' Assign new name
    retag = function(regex, old, new){
      if (grepl(regex, self$data$token[1])){
        self$data[1,"tag_before"] <- gsub(sprintf("<%s\\s+(.*?)>", old), sprintf("<%s \\1>", new), self$data[1,"tag_before"])
        self$data[nrow(self$data),"tag_after"] <- gsub(sprintf("</%s>", old), sprintf("</%s>", new), self$data[nrow(self$data),"tag_after"])
      }
      invisible(self)
    },
    
    #' @description
    #' Add tooltips to fulltexttable
    tooltips = function(tooltips){
      for (x in names(tooltips)){
        i <- which(self$data[["token"]] == x)
        self$data[i,"tag_before"] <- sprintf('%s<span class="tooltip">', self$data[i,"tag_before"])
        self$data[i,"tag_after"] <- sprintf('<span class="tooltiptext">%s</span></span>%s', tooltips[[x]], self$data[i,"tag_after"])
      }
      invisible(self)
    },
    
    #' @description 
    #' Split up table
    split = function(column = "token", regex){
      breaks <- cut(
        1:nrow(self$data),
        unique(c(grep(regex, self$data[[column]]), nrow(self$data))),
        right = FALSE
      )
      lapply(split(as.data.frame(self$data), breaks), function(x) FulltextData$new(x))
    },
    
    #' @description 
    #' Set visibility status.
    set_display = function(value = c("block", "none")){
      self$data[["tag_before"]] <- gsub("display:.*?(\\s|')", sprintf("display:%s\\1", value), self$data[["tag_before"]], perl = TRUE)
      invisible(self)
    },
    
    #' @description 
    #' Get visibility status.
    get_display = function(){
      i <- grep("<.*display:.*>", self$data[["tag_before"]])
      unique(gsub("^.*display:(.*?)(\\s|').*$", "\\1", self$data[i, "tag_before"]))
    }
    
  )
)
