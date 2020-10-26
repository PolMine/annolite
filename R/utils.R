.adjust_whitespace <- function(x){
  x[["whitespace"]] <- " "
  whitespace <- grep("^[\\.;,:!?\\)\\(]$", x[["token"]], perl = TRUE)
  if (length(whitespace) > 0L) x[whitespace, "whitespace"] <- ""
  x[1,"whitespace"] <- ""
  x
}


htmlize <- function(x){
  tokens_html <- sapply(
    x[["tokenstream"]],
    function(ts)
      paste0(sprintf('<span>%s</span><span id="%d">%s</span>', ts$whitespace, ts$id, ts$token), collapse = "")
  )
  paste0(
    sprintf('<%s style="%s" name = "%s">%s</%s>', x$element, x$style, x$name, tokens_html, x$element),
    collapse = ""
  )
}
