#' Customization for bootbox prompt dialog.
#' 
#' @export dialog_default_callback
#' @rdname dialog
dialog_default_callback <- c(
  "function (result) {",
    "var code_selected = $('#selection input:radio:checked').val();",
    "for (var id = window.id_left; id <= window.id_right; id++) {",
      "var spanEl = document.getElementById(id.toString());",
     "spanEl.style.backgroundColor = code_selected;",
    "}",
    "Shiny.onInputChange('code', code_selected);",
    "Shiny.onInputChange('annotation', result);",
    "Shiny.onInputChange('region', [id_left, id_right]);",
    "console.log(window.getSelection().toString());",
    "Shiny.onInputChange('text', window.highlighted_text);",
    "if (window.getSelection().empty) {  // Chrome",
      "window.getSelection().empty();",
    "} else if (window.getSelection().removeAllRanges) {  // Firefox",
    "window.getSelection().removeAllRanges();",
    "}",
  "}"
)

#' @rdname dialog
#' @param ... Definition of options in radio button group: Arguments are options, values are colors.
dialog_radio_buttons <- function(...){
  if (length(list(...)) == 0L){
    codes <- c(keep = "green", drop = "orange", reconsider = "grey")
  } else {
    codes <- as.character(list(...))
    names(codes) <- names(list(...))
  }
  
  paste(
    c('Add Annotation',
      '<hr/>',
      '<div id="selection" class="btn-group" data-toggle="buttons">',
      sprintf(
        '<label class="radio-inline"><input type="radio" name="optradio" checked value="%s">%s</label>',
        unname(codes), names(codes)
      ),
      '</div>'
    ), collapse = ""
  )
}
