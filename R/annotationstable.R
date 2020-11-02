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
#' @details The function \code{annotationstable()} serves as a constructor for
#'   an \code{annotationstable}. If called without arguments, an empty
#'   \code{annotationstable} is returned. If called with arguments, all input
#'   vectors need to have the same length.
#' 
#' @param text A \code{character} vector.
#' @param code A \code{character} vector.
#' @param color A \code{character} vector.
#' @param annotation A \code{character} vector.
#' @param start A \code{integer} vector
#' @param end integer A \code{integer} vector.
#' @export annotationstable
#' @rdname annotationstable
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


#' @details The auxiliary function `is.annotationstable()` checks whether
#'   the input objext `x` is a `annotationstable` object and whether it is
#'   valid. The return value is `TRUE` if `x` is a valid `annotationsstable`
#'   object and `FALSE` if not.
#' @param x An object to check whether it is a valid `annotationstable` object.
#' @rdname annotationstable
#' @export
is.annotationstable <- function(x){
  
  result <- TRUE # TRUE by default, will be FALSE if any condition is not met
  
  if ("annotationstable" %in% is(x)){
    warning("Object is not an 'annotationstable'.")
    result <- FALSE
  }
    
  if (isFALSE(inherits(x, "data.frame"))){
    warning("Object does not inherit from 'data.frame'.")
    result <- FALSE
  }
    
  # Now go through columns
  if (!is.character(x[["text"]])){
    warning("Object is not a valid 'annotationstable' object, column 'text' needs to be a character vector.")
    result <- FALSE
  }

  
  if (!is.character(x[["code"]])){
    warning("Object is not a valid 'annotationstable' object, column 'code' needs to be a character vector.")
    result <- FALSE
  }
  
  if (!is.character(x[["color"]])){
    warning("Object is not a valid 'annotationstable' object, column 'color' needs to be a character vector.")
    result <- FALSE
  }
  
  if (!is.character(x[["annotation"]])){
    warning("Object is not a valid 'annotationstable' object, column 'annotation' needs to be a character vector.")
    result <- FALSE
  }
  
  if (!is.integer(x[["start"]])){
    warning("Object is not a valid 'annotationstable' object, column 'start' needs to be a integer vector.")
    result <- FALSE
  }
  
  if (!is.integer(x[["end"]])){
    warning("Object is not a valid 'annotationstable' object, column 'end' needs to be a integer vector.")
    result <- FALSE
  }
  
  # End positions may not be lower than start positions
  if (any((x[["end"]] - x[["start"]]) < 0L)){
    warning("Values of end positions of annotations may not be smaller than start positions: Not true.")
    result <- FALSE
  }
  
  # None of the columns may include any NA value
  for (col in colnames(x)){
    if (any(is.na(x[[col]]))){
      warning(
        sprintf("Object is not a valid 'annotationstable' object, column '%s' includes NA values.", col)
      )
      result <- FALSE
    }
  }
  
  result
}

#' @details The auxiliary function `as.annotationstable()` will only accept
#'   objects of class `data.frame` and `annotationstable` as input `x` at this
#'   stage. If `x` is a `data.frame`, the object will be assigned the class
#'   `annotationstable`. If `x` is an `annotationstable`, it will remain
#'   unchanged. To ensure the validity of the object that is returned, the
#'   object is checked using `is.annotationstable()`. The return value is a
#'   valid `annotationstable` object.
#' @rdname annotationstable
#' @export
as.annotationstable <- function(x){
  
  if (is(x)[1] == "data.frame"){
    class(x) <- c("annotationstable", is(x))
  } else if (is(x)[1] == "annotationstable"){
    return(x)
  } else {
    warning(
      "Input object for function 'as.annotationstable()' is required ",
      "to be either a 'data.frame' or an 'annotationstable'."
    )
  }
  
  x[["text"]] <- as.character(x[["text"]])
  x[["code"]] <- as.character(x[["code"]])
  x[["color"]] <- as.character(x[["color"]])
  x[["annotation"]] <- as.character(x[["annotation"]])
  x[["start"]] <- as.integer(x[["start"]])
  x[["end"]] <- as.integer(x[["end"]])

  if (isFALSE(is.annotationstable(x))){
    warning("Input object x cannot be transformed to a (valid) 'annotationstable' object.")
  }
  
  x
}