setOldClass("fulltexttable")

#' Convert object to input for fulltext (table format).
#' 
#' @param name An id inserted into tags.
#' @param display The initial value of the html style argument. Either "block"
#'   or "none". Should usually be "block"
#' @param x An input object to be converted.
#' @param ... Further arguments defined by methods.
#' @export fulltexttable
#' @rdname fulltexttable
#' @importFrom methods callNextMethod
#' @importFrom polmineR get_token_stream as.utf8
#' @importFrom RcppCWB cl_struc2str cl_cpos2struc
#' @importFrom methods is as
#' @importFrom utils localeToCharset
#' @importClassesFrom polmineR slice subcorpus partition
setGeneric("fulltexttable", function(x, ...) standardGeneric("fulltexttable"))


#' @rdname fulltexttable
#' @exportMethod fulltexttable
#' @examples 
#' library(polmineR)
#' use("polmineR")
#' x <- corpus("REUTERS") %>% subset(id == "127")
#' tbl <- fulltexttable(x)
setMethod("fulltexttable", "subcorpus", function(x, display = "block", name = ""){
  retval <- data.frame(
    name = rep(name, times = nrow(x@cpos)),
    element = rep("para", times = nrow(x@cpos)),
    style = rep(sprintf("display:%s", display), times = nrow(x@cpos))
  )
  retval[["tokenstream"]] <- lapply(
    1L:nrow(x@cpos),
    function(i){
      ts <- get_token_stream(
        x@cpos[i,1]:x@cpos[i,2],
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
      .adjust_whitespace(df)
    }
  )
  class(retval) <- c("fulltexttable", is(retval))
  retval
})

#' @rdname fulltexttable
#' @examples
#' p <- partition("REUTERS", id = "127")
#' fli <- fulltexttable(p)
setMethod("fulltexttable", "partition", function(x, display = "block", name = ""){
  fulltexttable(as(x, "subcorpus"), display = display, name = name)
})


#' @rdname fulltexttable
#' @examples
#' library(polmineR)
#' use("polmineR")
#' 
#' x <- corpus("GERMAPARLMINI")
#' sp <- subset(x, speaker == "Volker Kauder" & date == "2009-11-10")
#' y <- fulltexttable(sp)
setMethod("fulltexttable", "plpr_subcorpus", function(x, display = "block", name = ""){
  retval <- callNextMethod()
  interjection_strucs <- RcppCWB::cl_cpos2struc(x@cpos[,1], corpus = x@corpus, s_attribute = "interjection")
  s_attr <- RcppCWB::cl_struc2str(interjection_strucs, corpus = x@corpus, s_attribute ="interjection")
  retval[["element"]] <- ifelse(s_attr == "interjection", "blockquote", retval[["element"]])
  fulltexttable(retval)
})


#' @param element An element to assign
#' @rdname fulltexttable
#' @examples 
#' x <- corpus("GERMAPARLMINI")
#' sp <-  subset(x, speaker == "Volker Kauder" & date == "2009-11-10")
#' y <- fulltexttable(sp)
#' headline <- fulltexttable(x = c("Volker", "Kauder", "(CDU)"), element = "h2")
#' y2 <- c(headline, y)
setMethod("fulltexttable", "character", function(x, display = "block", element = "para", name = ""){
  if (length(x) == 0L) return(NULL)
  retval <- data.frame(
    name = name,
    element = element,
    style = sprintf("display:%s", display)
  )
  retval[["tokenstream"]] <- list(.adjust_whitespace(data.frame(
    token = x,
    id = rep(-1, times = length(x)),
    whitespace = rep(" ", times = length(x)),
    stringsAsFactors = FALSE
  )))
  class(retval) <- c("fulltexttable", is(retval))
  retval
})


#' @rdname fulltexttable
setMethod("fulltexttable", "fulltexttable", function(x, display = "block", element = "para", name = "") x)

#' @rdname fulltexttable
setMethod("fulltexttable", "list", function(x, display = "block", element = "para", name = ""){
  do.call(rbind, lapply(x, fulltexttable, display = display, element = element, name = name))
})


