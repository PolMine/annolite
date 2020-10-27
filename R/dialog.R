#' Customize bootbox prompt dialog.
#' 
#' Auxiliary function to prepare HTML code to customize radio buttons and
#' possible selections as well as colors assigned to codes in the
#' [bootbox](http://bootboxjs.com/) prompt dialog that opens when text is
#' selected. The return value of the function is a `character` vector
#' with HTML. It is designed to be infused into JavaScript.
#' 
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
