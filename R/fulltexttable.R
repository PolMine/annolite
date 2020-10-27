setOldClass("fulltexttable")

#' Generate fulltexttable
#' 
#' The `fulltexttable` class is a superclass of the traditional `data.frame` to
#' represent the information to show the fulltext of a document (or documents)
#' as layouted HTML. Rows of a `fulltexttable` represent chunks of text
#' (paragraphs, headlines, blockquotes) that are formatted according to
#' information defined by the columns of the table. A `fulltexttable` has the
#' following columns:
#' - *name*: A `character` vector, serves as an identifier to distinguish the
#' content of different documents. Defaults to "", but required to be defined
#' when different documents are to be combined in one `fulltexttable` and
#' crosstalk is used to filter, or to select documents for display.
#' - *element*: The HTML element that wraps the tokens of a chunk of text that
#' are formatted according CSS instructions. For ordinary paragraphs, the
#' element 'para' should be used rathen than 'p' to avoid conclicts between
#' (potentially) CSSs.
#' - *style*: Content of the style attribute of the element. Used at this stage
#' to set the display mode. Defaults to "block" (chunk is displayed), but needs
#' to be "display:none" when crossstalk is used to filter documents, or to make
#' selections.
#' - *tokenstream*: A list of three-column `data.frame` objects that are nested 
#' into the cells of the `fulltexttable`. The HTML for fulltext display will be 
#' generated from this data upon calling the *annolite* HTML widget. Keeping the 
#' fulltext data in the nested `data.frame` ensures that data can be changed at
#' all times.
#' The `fulltexttable()` method is used to construct a `fulltexttable` from
#' different input objects.
#' 
#' @param x Object to be converted to `fulltexttable`. Can be a `character`
#'   vector with tokens of a chunk of text, or a `list` of `character` vectors
#'   representing chunks. Alternatively, objects used in the polmineR package
#'   can be processed (`subcorpus`, `partition`, `plpr_subcorpus`).
#' @param name A lenght-one `character` vector assigned to column "name" of
#'   `fulltexttable`. Used as name attribute of elements wrapping chunks of text
#'   to make selections between different documents. Defaults to "" as it will
#'   not be used unless crosstalk is used to skip through documents.
#' @param display The initial value of the html style argument. Either "block"
#'   or "none". Should usually be "block" by default so that text is displayed.
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
#' 
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


