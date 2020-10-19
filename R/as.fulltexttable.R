#' Convert object to input for fulltext (table format).
#' 
#' @param x The object to be converted.
#' @param ... Placeholder for further arguments defined by methods.
#' @export as.fulltexttable
#' @rdname as.fulltexttable
setGeneric("as.fulltexttable", function(x, ...) standardGeneric("as.fulltexttable"))

setOldClass("fulltexttable")

#' @param headline A headline to prepend.
#' @param name An id inserted into tags.
#' @param interjections If \code{TRUE}, an s-attribute "interjections" will be assumed to
#'   be available. When the s-attribute "interjections" is either "TRUE" or not "speech", 
#'   the passage of text is blockquoted.
#' @param display The initial value of the html style argument. Either "block"
#'   or "none". Should usually be "block"
#' @importFrom polmineR get_token_stream as.utf8
#' @importFrom RcppCWB cl_struc2str cl_cpos2struc
#' @importFrom methods is
#' @importClassesFrom polmineR slice subcorpus partition
#' @rdname as.fulltexttable
setMethod("as.fulltexttable", "slice", function(x, display = "block", headline = NULL, name = "", interjections = TRUE){
  if (!"slice" %in% is(x))stop("The function is implemented only for partition/subcorpus objects.")
  paragraphs <- lapply(
    seq_len(nrow(x@cpos)),
    function(i){
      ts <- get_token_stream(x@cpos[i,1]:x@cpos[i,2], p_attribute = "word", cpos = TRUE, corpus = x@corpus)
      df <- data.frame(
        id = as.integer(names(ts)),
        token = as.utf8(unname(ts), from = "latin1"),
        tag_before = " ",
        tag_after = "",
        stringsAsFactors = FALSE
      )
      whitespace <- grep("^[\\.;,:!?\\)\\(]$", df[["token"]], perl = TRUE)
      if (length(whitespace) > 0L) df[whitespace, "tag_before"] <- ""
      df[1,"tag_before"] <- ""
      
      if (interjections){
        s_attr <- RcppCWB::cl_struc2str(RcppCWB::cl_cpos2struc(x@cpos[i,1], corpus = x@corpus, s_attribute = "interjection"), corpus = x@corpus, s_attribute ="interjection")
        if (s_attr %in% c("speech", "FALSE")){
          df[1,"tag_before"] <- paste(df[1,"tag_before"], sprintf("<para style='display:%s' name='%s'>", display, name), sep = "")
          df[nrow(df), "tag_after"] <- paste(df[nrow(df), "tag_after"], "</para>", sep = "")
        } else {
          df[1,"tag_before"] <- paste(df[1,"tag_before"], sprintf("<blockquote style='display:%s' name ='%s'>", display, name), sep = "")
          df[nrow(df), "tag_after"] <- paste(df[nrow(df), "tag_after"], "</blockquote>", sep = "")
        }
      } else {
        df[1,"tag_before"] <- paste(df[1,"tag_before"], sprintf("<para style='display:%s' name='%s'>", display, name), sep = "")
        df[nrow(df), "tag_after"] <- paste(df[nrow(df), "tag_after"], "</para>", sep = "")
      }
      df
    }
  )
  y <- do.call(rbind, paragraphs)
  
  if (!is.null(headline)){
    headline_df <- data.frame(id = "", token = headline, tag_before = "", tag_after = "", stringsAsFactors = FALSE)
    headline_df[1, "tag_before"] <- sprintf("<h2 style='display:%s' name='%s'>", display, name) 
    headline_df[nrow(headline_df), "tag_after"] <- "</h2>"
    y <- rbind(headline_df, y)
  }
  class(y) <- c("fulltexttable", class(y))
  y
})

#' @export
#' @rdname as.fulltexttable
setMethod("as.fulltexttable", "data.frame", function(x, ...){
  class(x) <- c("fulltexttable", class(x))
  x
})


#' @param beautify Remove whitespace before interpunctation.
#' @param tag A tag.
#' @rdname as.fulltexttable
setMethod("as.fulltexttable", "character", function(x, display = "block", tag = "para", name = "", beautify = TRUE){
  if (length(x) == 0L) return(NULL)
  df <- data.frame(token = x, tag_before = " ", tag_after = "", stringsAsFactors = FALSE)
  if (beautify){
    whitespace <- grep("^[\\.;,:!?\\)\\(]$", df[["token"]], perl = TRUE)
    if (length(whitespace) > 0L) df[whitespace, "tag_before"] <- ""
  }
  df[1,"tag_before"] <- sprintf("<%s style='display:block' name='%s'>", tag, name)
  df[nrow(df), "tag_after"] <- sprintf("</%s>", tag)
  class(df) <- c("fulltexttable", class(df))
  df
})

#' @rdname as.fulltexttable
setMethod("as.fulltexttable", "list", function(x, display = "block", tag = "para", beautify = TRUE){
  li <- lapply(x, as.fulltexttable, display = display, tag = tag, beautify = beautify)
  y <- do.call(rbind, li)
  class(y) <- c("fulltexttable", class(y))
  y
})

#' @rdname as.fulltexttable
setMethod("as.fulltexttable", "fulltexttable", function(x, ...) x)


setOldClass("FulltextData")

#' @rdname as.fulltexttable
setMethod("as.fulltexttable", "FulltextData", function(x, ...){
  x$data
})
