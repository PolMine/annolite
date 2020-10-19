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
  apply(
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
  list(
    list(
      element = tag,
      attributes = list(style = sprintf("display:%s", display), name = name),
      tokenstream = df
    )
  )
})


#' @rdname as.fulltextlist
setMethod("as.fulltextlist", "fulltextlist", function(x, ...) x)


setOldClass("FulltextData")

#' @rdname as.fulltextlist
setMethod("as.fulltextlist", "FulltextData", function(x, ...) x$data)
