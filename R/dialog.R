#' Customization for bootbox prompt dialog.
#' 
#' @export dialog_default_callback
#' @rdname dialog
dialog_default_callback <- c(
  "function (result) {",
    
    "var i = document.annotations.id_left.length - 1;",
    "var code_selected = $('#selection input:radio:checked').val();",
    "document.annotations.code.push(code_selected);",
    "document.annotations.annotation.push(result);",
    
    "for (var id = document.annotations.id_left[i]; id <= document.annotations.id_right[i]; id++) {",
      "document.getElementById(id.toString()).style.backgroundColor = code_selected;",
    "};",
    
    "document.annotationsCreated++;",
    "console.log(document.annotationsCreated);",
    "Shiny.onInputChange('annotations_created', document.annotationsCreated);",
    "Shiny.onInputChange('annotations_table', document.annotations);",
    "console.log(document.annotations);",
  
    "if (window.getSelection().empty) {  // Chrome",
      "window.getSelection().empty();",
    "} else if (window.getSelection().removeAllRanges) {  // Firefox",
      "window.getSelection().removeAllRanges();",
    "}",
  
  "}"
)

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
