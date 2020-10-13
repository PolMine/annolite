#' Customization for bootbox prompt dialog.
#' 
#' @export dialog_default_callback
#' @rdname dialog
dialog_default_callback <- function(){
  readLines(system.file(package = "annolite", "js", "callback.js"))
}
  
  
#' @export dialog_radio_buttons
#' @rdname dialog
#' @param ... Definition of options in radio button group: Arguments are options, values are colors.
dialog_radio_buttons <- function(...){
  if (length(list(...)) == 0L){
    codes <- c(keep = "green", drop = "orange", reconsider = "grey")
  } else {
    codes <- as.character(list(...))
    names(codes) <- names(list(...))
  }
  
  is_checked <- c(" checked", rep("", length(codes) - 1L))
  paste(
    c('Add Annotation',
      '<hr/>',
      '<div id="selection" class="btn-group" data-toggle="buttons">',
      sprintf(
        '<label class="radio-inline"><input type="radio" name="radioGroup" value="%s"%s>%s</label>',
        unname(codes), is_checked, names(codes)
      ),
      '</div>'
    ), collapse = ""
  )
}
