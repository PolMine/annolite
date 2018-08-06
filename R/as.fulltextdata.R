#' Convert object to input for fulltext.
#' 
#' @param x The object to be converted.
#' @param headline A headline to append.
#' @export as.fulltextdata
#' @examples
#' library(polmineR)
#' use("polmineR")
#' P <- partition("GERMAPARLMINI", speaker = "Volker Kauder", date = "2009-11-10")
#' D <- as.fulltextdata(P, headline = "Volker Kauder (CDU)")
#' fulltext(D)
#' @importFrom polmineR getTokenStream as.utf8
as.fulltextdata <- function(x, headline){
  if ("partition" %in% is(x)){
    data <- apply(
      x@cpos,
      1, 
      function(row){
        ts <- getTokenStream(row[1]:row[2], p_attribute = "word", cpos = TRUE, corpus = "GERMAPARLMINI")
        s_attr <- polmineR:::CQI$struc2str(polmineR:::CQI$cpos2struc(row[1], corpus = "GERMAPARLMINI", s_attribute = "interjection"), corpus = "GERMAPARLMINI", s_attribute ="interjection")
        list(
          element = if (s_attr == "speech") "p" else "blockquote",
          tokenstream = data.frame(token = as.utf8(unname(ts), from = "latin1"), cpos = as.integer(names(ts)))
        )
      }
    )
    
  } else {
    stop("not yet implemented")
  }
  
  headline <- list(
    list(
      element = "h2",
      tokenstream = data.frame(
        token = headline,
        cpos = rep("", times = length(headline))
      )
    )
  )
  data <- c(headline, data)
  data
}

