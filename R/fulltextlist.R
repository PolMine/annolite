setOldClass("fulltextlist")

#' Convert object to input for fulltext (table format).
#' 
#' @param name An id inserted into tags.
#' @param display The initial value of the html style argument. Either "block"
#'   or "none". Should usually be "block"
#' @param x An input object to be converted.
#' @param ... Further arguments defined by methods.
#' @export fulltextlist
#' @rdname fulltextlist
#' @importFrom methods callNextMethod
#' @importFrom polmineR get_token_stream as.utf8
#' @importFrom RcppCWB cl_struc2str cl_cpos2struc
#' @importFrom methods is as
#' @importFrom utils localeToCharset
#' @importClassesFrom polmineR slice subcorpus partition
setGeneric("fulltextlist", function(x, ...) standardGeneric("fulltextlist"))


#' @rdname fulltextlist
#' @exportMethod fulltextlist
#' @examples 
#' \dontrun{
#' x <- corpus("REUTERS") %>% subset(id == "127")
#' fli <- fulltextlist(x)
#' }
setMethod("fulltextlist", "subcorpus", function(x, display = "block", name = ""){
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

#' @rdname fulltextlist
#' @examples
#' \dontrun{
#' p <- partition("REUTERS", id = "127")
#' fli <- fulltextlist(p)
#' }
setMethod("fulltextlist", "partition", function(x, display = "block", name = ""){
  fulltextlist(as(x, "subcorpus"), display = display, name = name)
})


#' @rdname fulltextlist
#' @examples
#' \dontrun{
#' library(polmineR)
#' use("polmineR")
#' x <- corpus("GERMAPARLMINI")
#' sp <- subset(x, speaker == "Volker Kauder" & date == "2009-11-10")
#' y <- fulltextlist(sp)
#' }
setMethod("fulltextlist", "plpr_subcorpus", function(x, display = "block", name = ""){
  retval <- callNextMethod()
  interjection_strucs <- RcppCWB::cl_cpos2struc(x@cpos[,1], corpus = x@corpus, s_attribute = "interjection")
  s_attr <- RcppCWB::cl_struc2str(interjection_strucs, corpus = x@corpus, s_attribute ="interjection")
  retval <- lapply(
    seq_along(retval),
    function(i){
      if (s_attr[[i]] == "interjection") retval[[i]][["element"]] <- "blockquote"
      retval[[i]]
    }
  )
  fulltextlist(retval)
})


#' @param element An element to assign
#' @param beautify Remove whitespace before interpunctation.
#' @rdname fulltextlist
#' @examples 
#' \dontrun{
#' x <- corpus("GERMAPARLMINI")
#' sp <-  subset(x, speaker == "Volker Kauder" & date == "2009-11-10")
#' y <- fulltextlist(sp)
#' headline <- fulltextlist(x = c("Volker", "Kauder", "(CDU)"), tag = "h2")
#' y2 <- c(headline, y)
#' }
setMethod("fulltextlist", "character", function(x, display = "block", element = "para", name = "", beautify = TRUE){
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
      element = element,
      attributes = list(style = sprintf("display:%s", display), name = name),
      tokenstream = df
    )
  )
  class(retval) <- c("fulltextlist", is(retval))
  retval
})


#' @rdname fulltextlist
setMethod("fulltextlist", "fulltextlist", function(x, ...) x)

#' @rdname fulltextlist
setMethod("fulltextlist", "list", function(x){
  class(x) <- c("fulltextlist", is(x))
  x
})

#' @rdname fulltextlist
setMethod("fulltextlist", "data.frame", function(x, element = "para", display = "block", name = ""){
  retval <- list(
    list(
      element = element,
      attributes = list(style = sprintf("display:%s", display), name = name),
      tokenstream = x
    )
  )
  class(retval) <- c("fulltextlist", is(retval))
  retval
})


####################### name #######################


#' Manage names of fulltextlist 
#' 
#' @param x A \code{fulltextlist} object.
#' @param value The value to assign.
#' @rdname name
#' @importFrom polmineR name name<-
#' @exportMethod name<-
#' @examples
#' \dontrun{
#' li <- corpus("REUTERS") %>%  subset(id == "127") %>% fulltextlist()
#' name(li)
#' name(li) <- "reuters127"
#' name(li)
#' }
setReplaceMethod("name", signature = "fulltextlist", function(x, value){
  retval <- lapply(
    seq_along(x),
    function(i){ x[[i]]$attributes$name <- value; x[[i]] }
  )
  fulltextlist(retval)
})

#' @rdname name
#' @exportMethod name
setMethod("name", signature = "fulltextlist", function(x){
  unique(sapply(x, function(chunk) chunk$attributes$name))
})


########################## display ############################

#' Change display mode of fulltextlist
#' 
#' @param x A \code{fulltextlist} object.
#' @param value Either "block" or "none".
#' @rdname display
#' @exportMethod display
#' @examples 
#' \dontrun{
#' li <- corpus("REUTERS") %>%  subset(id == "127") %>% fulltextlist()
#' display(li)
#' display(li) <- "none"
#' display(li)
#' }
setGeneric("display", function(x) standardGeneric("display") )

#' @rdname display
#' @exportMethod display
setMethod("display", "fulltextlist", function(x){
  unique(sapply(x, function(z) strsplit(z$attributes$style, ":")[[1]][[2]]))
})

#' @rdname display
#' @exportMethod display<-
setGeneric("display<-", function(x, value) standardGeneric("display<-"))

#' @rdname display
#' @exportMethod display<-
setReplaceMethod("display", signature = "fulltextlist", function(x, value = c("block", "none")){
  retval <- lapply(x, function(chunk){chunk$attributes$style <- sprintf("display:%s", value); chunk})
  fulltextlist(retval)
})


################### split #######################

#' Split up fulltextlist
#' 
#' @param x A \code{fulltextlist} object
#' @param regex A regular expression.
#' @rdname split
#' @export
setMethod("split", "fulltextlist", function(x, regex){
  df <- do.call(rbind, lapply(x, function(chunk) chunk$tokenstream))
  breaks <- cut(
    1L:nrow(df),
    unique(c(grep(regex, df[["token"]]), nrow(x))),
    right = FALSE
  )
  chunks <- split(df, breaks)
  retval <- lapply(chunks, function(a) fulltextlist(a))
})


#################### element #######################

#' Get and change element tag
#' 
#' @param x A \code{fulltextlist} object
#' @param value New value.
#' @exportMethod element
#' @rdname element
#' @examples 
#' \dontrun{
#' li <- corpus("REUTERS") %>%  subset(id == "127") %>% fulltextlist()
#' element(li)
#' element(li) <- "h2"
#' name(li)
#' }
setGeneric("element", function(x) standardGeneric("element"))

#' @exportMethod element
#' @rdname element
setMethod("element", "fulltextlist", function(x){
  sapply(x, function(chunk) chunk$element)
})

#' @exportMethod element<-
#' @rdname element
setGeneric("element<-", function(x, value) standardGeneric("element<-"))

#' @param value Value to assign to element.
#' @exportMethod element<-
#' @rdname element
setReplaceMethod("element", "fulltextlist", function(x, value){
  retval <- lapply(x, function(chunk) chunk$element <- value)
  fulltextlist(retval)
})


################ c ##########

#' @rdname fulltextlist
#' @export
c.fulltextlist <- function(...){
  retval <- unlist(x = list(...), recursive = FALSE)
  fulltextlist(retval)
}
