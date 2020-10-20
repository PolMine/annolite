#' Create empty annotationstable
#' 
#' @param text character
#' @param code character
#' @param color character
#' @param annotation character
#' @param start integer
#' @param end integer
#' @export annotationstable
annotationstable <- function(text = character(), code = character(), color = character(), annotation = character(), start = integer(), end = integer()){
  y <- data.frame(
    text = text,
    code = code,
    color = color,
    annotation = annotation,
    start = start,
    end = end
  )
  class(y) <- c("annotations", is(y))
  y
}
