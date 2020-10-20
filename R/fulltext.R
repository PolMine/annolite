#' Fulltext output htmlwidget.
#' 
#' @param x The data.
#' @param annotations A table with annotations.
#' @param width The width of the widget.
#' @param group Name of the crosstalk group, see ....
#' @param height The height of the widget.
#' @param box Logical, whether to put text into a box.
#' @param ... Further arguments to be defined by individual methods.
#' @importFrom htmlwidgets createWidget sizingPolicy
#' @importFrom crosstalk is.SharedData
#' @export
#' @rdname fulltext
#' @exportMethod fulltext
setGeneric("fulltext", function(x, ...) standardGeneric("fulltext"))


#' @rdname fulltext
#' @exportMethod fulltext
setMethod("fulltext", "fulltextlist", function(x, annotations = NULL, width = "100%", height = NULL, box = TRUE, group = NULL) {
  if (is.null(annotations)) annotations <- .annotations()
  createWidget(
    "fulltext",
    package = "annolite",
    x = list(
      data = list(paragraphs = x, annotations = annotations),
      settings = list(box = box, crosstalk_key = NULL, crosstalk_group = group)
    ),
    width = width,
    height = height,
    dependencies = crosstalk::crosstalkLibs(),
    sizingPolicy(
      browser.fill = TRUE,
      viewer.defaultHeight = 800L,
      browser.defaultHeight = 800L,
      viewer.fill = TRUE,
      knitr.figure = FALSE,
      knitr.defaultWidth = 800L,
      knitr.defaultHeight = 400L
    )
  )
})

setOldClass("SharedData")

#' @rdname fulltext
#' @exportMethod fulltext
setMethod("fulltext", "SharedData", function(x, annotations = NULL, width = "100%", height = NULL, box = TRUE, group = x$groupName()) {
  fulltext(
    x = x$origData(),
    annotations = annotations,
    width = width, height = height, box = box,
    group = group
  )
})


#' @rdname fulltext
#' @exportMethod fulltext
#' @importFrom crosstalk bscols
setMethod("fulltext", "list", function(x, annotations = NULL, width = "100%", height = NULL, box = TRUE, group = "fulltext"){
  
  document_ids <- sapply(x, name)
  
  # x <- lapply(x, function(fli){display(fli) <- "block"; fli})
  x_flat <- do.call(c, x)
  display(x_flat) <- "none"

  x_sd <- crosstalk::SharedData$new(x_flat, ~document_id, group = group) # key will be unused, omit it
  
  doc_df <- data.frame(document_id = document_ids)
  doc_df_sd <- crosstalk::SharedData$new(doc_df, ~document_id, group = group)
  doc_datatable_sd <- DT::datatable(
    doc_df_sd,
    options = list(lengthChange = TRUE, pageLength = 8L, pagingType = "simple", dom = "tp"),
    rownames = NULL, width = "100%", selection = "single"
  )
  
  # using filter_select() not possible, because fn will try to learn levels from 
  # data - but this is not how this works
  bscols(
    widths = c(4,8),
    doc_datatable_sd,
    fulltext(x_sd, width = width, height = height, box = box)
  )
})