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
#' @importFrom R6 R6Class
#' @examples 
#' library(polmineR)
#' k <- corpus("GERMAPARLMINI") %>%
#'   subset(speaker == "Volker Kauder") %>%
#'   subset(date == "2009-11-10")
#'   
#' F <- FulltextData$new(k, display = "block")
#' m <- cpos(k, query = "Opposition")
#' anno <- data.frame(color = "yellow", start = m[,1], end = m[,2])
#' # F$tooltips(tooltips = list(Opposition = "A", Regierung = "B"))
FulltextData <- R6::R6Class(
  
  classname = "FulltextData",
  
  public = list(
    
    data = NULL, # a data.frame

    #' @description 
    #' Initialize a new instance of class \code{CorpusData}.
    #' @return A class \code{CorpusData} object.
    initialize = function(input, ...){
      if (!missing(input)) self$data = as.fulltextlist(input, ...)
      invisible(self)
    },
    
    #' @description 
    #' Assign new name
    rename = function(name){
      lapply(seq_along(self$data), function(i) self$data[[i]]$attributes$name <- name)
      invisible(self)
    }, 
    
    #' @description 
    #' Get name(s).
    get_name = function(){
      unique(sapply(self$data, function(x) x$attributes$name))
    },
    
    #' @description 
    #' Assign new name
    retag = function(regex, old, new){
      lapply(
        seq_along(self$data),
        function(i) if (grepl(regex, self$data[[i]]$tokenstream$token[1])) self$data[[i]]$element <- new 
      )
      invisible(self)
    },
    
    #' @description 
    #' Split up table
    split = function(column = "token", regex){
      df <- do.call(rbind, lapply(self$data, function(x) x$tokenstream))
      breaks <- cut(
        1:nrow(df),
        unique(c(grep(regex, self$data[[column]]), nrow(self$data))),
        right = FALSE
      )
      lapply(split(df, breaks), function(x) FulltextData$new(as.fulltextlist(x)))
    },
    
    #' @description 
    #' Set visibility status.
    set_display = function(value = c("block", "none")){
      lapply(seq_along(self$data), function(i) self$data[[i]]$attributes$style <- sprintf("display:%s", value))
      invisible(self)
    },
    
    #' @description 
    #' Get visibility status.
    get_display = function(){
      unique(sapply(self$data, function(x) strsplit(x$attributes$style, ":")[[1]][[2]]))
    }
  )
)
