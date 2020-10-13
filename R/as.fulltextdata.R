#' @rdname as.fulltextdata
#' @export as.fulltextdata
as.fulltextdata <- function(x, headline) UseMethod("as.fulltextdata", x)


#' Convert object to input for fulltext.
#' 
#' @param x The object to be converted.
#' @param headline A headline to append.
#' @export
#' @examples
#' \dontrun{
#' library(polmineR)
#' use("polmineR")
#' P <- partition("GERMAPARLMINI", speaker = "Volker Kauder", date = "2009-11-10")
#' D <- as.fulltextdata(P, headline = "Volker Kauder (CDU)")
#' fulltext(D)
#' }
#' @importFrom polmineR get_token_stream
#' @importFrom polmineR as.utf8
#' @importFrom utils localeToCharset
#' @importFrom RcppCWB cl_struc2str cl_cpos2struc
#' @rdname as.fulltextdata
as.fulltextdata.plpr_partition <- function(x, headline){
  paragraphs <- apply(
    x@cpos, 1, 
    function(row){
      ts <- get_token_stream(row[1]:row[2], p_attribute = "word", cpos = TRUE, corpus = x@corpus, encoding = x@encoding)
      s_attr <- RcppCWB::cl_struc2str(RcppCWB::cl_cpos2struc(row[1], corpus = x@corpus, s_attribute = "interjection"), corpus = x@corpus, s_attribute ="interjection")
      list(
        element = if (s_attr %in% c("speech", "FALSE")) "p" else "blockquote",
        tokenstream = data.frame(token = as.utf8(unname(ts), from = localeToCharset()), id = as.integer(names(ts)))
      )
    }
  )
  
  
  headline <- list(
    list(
      element = "h2",
      tokenstream = data.frame(token = headline, id = rep("", times = length(headline)))
    )
  )
  paragraphs <- c(headline, paragraphs)
  list(
    paragraphs = paragraphs,
    annotations = data.frame(
      text = character(),
      code = character(),
      annotation = character(),
      id_left = integer(),
      id_right = integer()
    )
  )
}


#' @export
#' @rdname as.fulltextdata
as.fulltextdata.subcorpus <- function(x, headline){
  paragraphs <- apply(
    x@cpos, 1, 
    function(row){
      ts <- get_token_stream(row[1]:row[2], p_attribute = "word", cpos = TRUE, corpus = x@corpus, encoding = x@encoding)
      list(
        element = "p",
        tokenstream = data.frame(token = as.utf8(unname(ts), from = localeToCharset()), id = as.integer(names(ts)))
      )
    }
  )
  
  
  headline <- list(
    list(
      element = "h2",
      tokenstream = data.frame(token = headline, id = rep("", times = length(headline)))
    )
  )
  paragraphs <- c(headline, paragraphs)
  list(
    paragraphs = paragraphs,
    annotations = data.frame(
      text = character(),
      code = character(),
      annotation = character(),
      id_left = integer(),
      id_right = integer()
    )
  )
}

