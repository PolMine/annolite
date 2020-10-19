#' @rdname fulltext
#' @export fulltext
fulltext <- function(x, width = NULL, height = NULL, box = TRUE, group = NULL) UseMethod("fulltext", x)


#' Fulltext output htmlwidget.
#' 
#' @param x The data.
#' @param width The width of the widget.
#' @param group Name of the crosstalk group, see ....
#' @param height The height of the widget.
#' @param box Logical, whether to put text into a box.
#' @importFrom htmlwidgets createWidget sizingPolicy
#' @importFrom crosstalk is.SharedData
#' @export
#' @rdname fulltext
fulltext.data.frame <- function(x, width = "100%", height = NULL, box = TRUE, group = NULL) {
  
  createWidget(
    "fulltext",
    package = "annolite",
    x = list(
      data = x,
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
}


#' @export
#' @rdname fulltext
fulltext.SharedData <- function(x, width = "100%", height = NULL, box = TRUE, group = x$groupName()) {
  fulltext.data.frame(
    x = x$origData(),
    width = width, height = height, box = box,
    group = group
  )
}

#' @export
#' @rdname fulltext
fulltext.FulltextData <- function(x, width = "100%", height = NULL, box = TRUE, group = NULL) {
  fulltext.data.frame(x = x$data, width = width, height = height, box = box, group = group)
}

#' @export
#' @rdname fulltext
#' @importFrom crosstalk bscols
fulltext.list <- function(x, width = "100%", height = NULL, box = TRUE, group = "fulltext"){
  
  document_ids <- sapply(x, function(x) x$get_name())
  
  lapply(seq_along(x), function(i) x[[i]]$set_display(value = "none"))

  x_sd <- crosstalk::SharedData$new(FulltextData$new(x)$data, ~document_id, group = group)
  
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
    fulltext.SharedData(x_sd, width = width, height = height, box = box)
  )
}


