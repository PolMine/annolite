#' @include utils.R
NULL

#' @rdname as.annotatordata
#' @export as.annotatordata
as.annotatordata <- function(x, headline) UseMethod("as.annotatordata", x)


#' Convert object to input for annotator htmlwidget.
#' 
#' @param x The object to be converted.
#' @param headline A headline to append.
#' @export
#' @examples
#' \dontrun{
#' library(polmineR)
#' use("polmineR")
#' P <- partition("GERMAPARLMINI", speaker = "Volker Kauder", date = "2009-11-10")
#' D <- as.annotatordata(P, headline = "Volker Kauder (CDU)")
#' annotate(D)
#' }
#' @importFrom polmineR get_token_stream
#' @importFrom polmineR as.utf8
#' @importFrom utils localeToCharset
#' @importFrom RcppCWB cl_struc2str cl_cpos2struc
#' @rdname as.annotatordata
as.annotatordata.plpr_partition <- function(x, headline = NULL){
  paragraphs <- apply(
    x@cpos, 1, 
    function(row){
      ts <- get_token_stream(row[1]:row[2], p_attribute = "word", cpos = TRUE, corpus = x@corpus, encoding = x@encoding)
      s_attr <- RcppCWB::cl_struc2str(RcppCWB::cl_cpos2struc(row[1], corpus = x@corpus, s_attribute = "interjection"), corpus = x@corpus, s_attribute ="interjection")
      df <- data.frame(token = as.utf8(unname(ts), from = localeToCharset()), id = as.integer(names(ts)))
      df <- .adjust_whitespace(df)
      y <- list(
        element = if (s_attr %in% c("speech", "FALSE")) "p" else "blockquote",
        tokenstream = df
      )
      y
    }
  )
  
  if (!is.null(headline)){
    headline <- list(
      list(
        element = "h2",
        tokenstream = data.frame(token = headline, id = rep("", times = length(headline)), whitespace = "")
      )
    )
  }
  
  paragraphs <- c(headline, paragraphs)
  retval <- list(paragraphs = paragraphs, annotations = .annotations())
  class(retval) <- c("annotatordata", is(retval))
  retval
}


#' @export
#' @rdname as.annotatordata
as.annotatordata.subcorpus <- function(x, headline = NULL){
  paragraphs <- apply(
    x@cpos, 1, 
    function(row){
      ts <- get_token_stream(row[1]:row[2], p_attribute = "word", cpos = TRUE, corpus = x@corpus, encoding = x@encoding)
      df <- data.frame(token = as.utf8(unname(ts), from = localeToCharset()), id = as.integer(names(ts)), whitespace = " ")
      df <- .adjust_whitespace(df)
      list(element = "p", tokenstream = df)
    }
  )
  
  if (isFALSE(is.null(headline))){
    headline <- list(
      list(
        element = "h2",
        tokenstream = data.frame(token = headline, id = rep("", times = length(headline)), whitespace = "")
      )
    )
  }
  
  paragraphs <- c(headline, paragraphs)
  retval <- list(paragraphs = paragraphs, annotations = .annotations())
  class(retval) <- c("annotatordata", is(retval))
  retval
}

.adjust_whitespace <- function(x){
  x[["whitespace"]] <- " "
  whitespace <- grep("^[\\.;,:!?\\)\\(]$", x[["token"]], perl = TRUE)
  if (length(whitespace) > 0L) x[whitespace, "whitespace"] <- ""
  x[1,"whitespace"] <- ""
  x
  
}

#' @rdname as.annotatordata
#' @export is.annotatordata
is.annotatordata <- function(x) inherits(x, "annotatordata")
