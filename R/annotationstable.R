#' Create annotationstable
#' 
#' @description
#' The annolite package uses an \code{annotationstable} to store and manage the
#' annotations of an document. An \code{annotationstable} object is a S3
#' superclass of a \code{data.frame}. An \code{annotationstable} is a
#' \code{data.frame} with the following columns:
#' 
#' * \emph{text}: The original text that has been selected to serve as a basis
#' for an annotation. Note that text selection is not required to cover whole
#' words. Parts of words may have been selected.
#' * \emph{code}: A code that has been assigned to an annotated passage of text.
#' Available codes need to be predefined before an annotation exercise.
#' * \emph{color}: The color used to highlight annotated token sequences. Each
#' color needs to reflect one code.
#' * \emph{annotation}: An explanatory note on the code that has been assigned.
#' * \emph{start}: ID of the first token that has been annotated. If the
#' annotated document is a subcorpus of a CWB corpus, the token ID is the
#' \code{integer} corpus position.
#' * \emph{end}: ID of the last token that has been annotated. If the annotated
#' document is a subcorpus of a CWB corpus, the token ID is the \code{integer}
#' corpus position.
#' 
#' The function \code{annotationstable()} serves as a constructor for an
#' \code{annotationstable}. If called without arguments, an empty
#' \code{annotationstable} is returned. If called with arguments, all input
#' vectors need to have the same length.
#' 
#' @param text A \code{character} vector.
#' @param code A \code{character} vector.
#' @param color A \code{character} vector.
#' @param annotation A \code{character} vector.
#' @param start A \code{integer} vector
#' @param end integer A \code{integer} vector.
#' @export annotationstable
#' @examples
#' empty_annotationstable <- annotationstable()
annotationstable <- function(text = character(), code = character(), color = character(), annotation = character(), start = integer(), end = integer()){
  
  # Check that all vectors have same length
  if (length(unique(sapply(list(text,code, color, annotation, start, end), length))) != 1L){
    stop(
      "Cannot create 'annotationstable' object: ",
      "All input vectors are required to have the same langth"
    )
  }
  
  if (!is.character(text)) stop("Argument 'text' needs to be a character vector.")
  if (!is.character(code)) stop("Argument 'code' needs to be a character vector.")
  if (!is.character(color)) stop("Argument 'color' needs to be a character vector.")
  if (!is.character(annotation)) stop("Argument 'annotation' needs to be a character vector.")
  if (!is.integer(start)) stop("Argument 'start' needs to be a integer vector.")
  if (!is.integer(end)) stop("Argument 'end' needs to be a integer vector.")
  
  retval <- data.frame(
    text = text,
    code = code,
    color = color,
    annotation = annotation,
    start = start,
    end = end
  )
  class(retval) <- c("annotationstable", is(retval))
  retval
}
