.annotations <- function(text = character(), code = character(), color = character(), annotation = character(), start = integer(), end = integer()){
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
