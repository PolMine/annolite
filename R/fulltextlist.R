#' Convert object to input for fulltext (table format).
#' 
#' @param x An input object to be converted.
#' @param ... Further arguments defined by methods.
#' @export as.fulltextlist
#' @rdname as.fulltextlist
#' @importFrom methods callNextMethod
setGeneric("as.fulltextlist", function(x, ...) standardGeneric("as.fulltextlist"))

setOldClass("fulltextlist")

#' @param name An id inserted into tags.
#' @param display The initial value of the html style argument. Either "block"
#'   or "none". Should usually be "block"
#' @importFrom polmineR get_token_stream as.utf8
#' @importFrom RcppCWB cl_struc2str cl_cpos2struc
#' @importFrom methods is as
#' @importFrom utils localeToCharset
#' @importClassesFrom polmineR slice subcorpus partition
#' @rdname as.fulltextlist
setMethod("as.fulltextlist", "subcorpus", function(x, display = "block", name = ""){
  retval <- apply(
    x@cpos, MARGIN = 1L, 
    function(region){
      ts <- get_token_stream(
        region[1]:region[2],
        p_attribute = "word",
        cpos = TRUE,
        corpus = x@corpus,
        encoding = x@encoding
      )
      df <- data.frame(
        token = as.utf8(unname(ts), from = localeToCharset()),
        id = as.integer(names(ts)),
        whitespace = " "
      )
      df <- .adjust_whitespace(df)
      list(
        element = "para",
        attributes = list(style = sprintf("display:%s", display), name = name),
        tokenstream = df
      )
    }
  )
  class(retval) <- c("fulltextlist", is(retval))
  retval
})

#' @rdname as.fulltextlist
setMethod("as.fulltextlist", "partition", function(x, display = "block", name = ""){
  as.fulltextlist(as(x, "subcorpus"), display = display, name = name)
})


#' @rdname as.fulltextlist
#' @examples
#' \dontrun{
#' library(polmineR)
#' use("polmineR")
#' x <- corpus("GERMAPARLMINI")
#' sp <- subset(x, speaker == "Volker Kauder" & date == "2009-11-10")
#' y <- as.fulltextlist(sp)
#' }
setMethod("as.fulltextlist", "plpr_subcorpus", function(x, display = "block", name = ""){
  retval <- callNextMethod()
  interjection_strucs <- RcppCWB::cl_cpos2struc(x@cpos[,1], corpus = x@corpus, s_attribute = "interjection")
  s_attr <- RcppCWB::cl_struc2str(interjection_strucs, corpus = x@corpus, s_attribute ="interjection")
  lapply(
    seq_along(retval),
    function(i){
      if (s_attr[[i]] == "interjection") retval[[i]][["element"]] <- "blockquote"
      retval[[i]]
    }
  )
})



#' @param beautify Remove whitespace before interpunctation.
#' @param tag A tag.
#' @rdname as.fulltextlist
#' @examples 
#' \dontrun{
#' x <- corpus("GERMAPARLMINI")
#' sp <-  subset(x, speaker == "Volker Kauder" & date == "2009-11-10")
#' y <- as.fulltextlist(sp)
#' headline <- as.fulltextlist(x = c("Volker", "Kauder", "(CDU)"), tag = "h2")
#' y2 <- c(headline, y)
#' }
setMethod("as.fulltextlist", "character", function(x, display = "block", tag = "para", name = "", beautify = TRUE){
  if (length(x) == 0L) return(NULL)
  df <- data.frame(
    token = x,
    id = -1,
    whitespace = " ",
    stringsAsFactors = FALSE
  )
  df <- .adjust_whitespace(df)
  retval <- list(
    list(
      element = tag,
      attributes = list(style = sprintf("display:%s", display), name = name),
      tokenstream = df
    )
  )
  class(retval) <- c("fulltextlist", is(retval))
  retval
})


#' @rdname as.fulltextlist
setMethod("as.fulltextlist", "fulltextlist", function(x, ...) x)


setOldClass("FulltextData")

#' @rdname as.fulltextlist
setMethod("as.fulltextlist", "FulltextData", function(x, ...) x$data)


#' Manage Data for fulltext annotation und display widget.
#' 
#' @rdname fulltextlist-methods
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
#' F <- FulltextData$new(k, display = "block")
#' m <- cpos(k, query = "Opposition")
#' anno <- data.frame(color = "yellow", start = m[,1], end = m[,2])
#' # F$tooltips(tooltips = list(Opposition = "A", Regierung = "B"))




#' @description The \code{name<-} replace method can be used ...
#' @rdname fulltextlist-methods
#' @importFrom polmineR name name<-
#' @exportMethod name<-
setReplaceMethod("name", signature = "fulltextlist", function(x, value){
  lapply(seq_along(x), function(i){x[[i]]$attributes$name <- name; x})
})

#' @rdname fulltextlist-methods
#' @exportMethod name
setMethod("name", signature = "fulltextlist", function(x){
  unique(sapply(self$data, function(x) x$attributes$name))
}


setGeneric("")

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
