function (result) {
    
    var i = document.annotations.id_left.length - 1;
    var code_selected = $('input[name="radioGroup""]:checked').parent().text()
    document.annotations.code.push(code_selected);
    document.annotations.annotation.push(result);
    
    for (var id = document.annotations.id_left[i]; id <= document.annotations.id_right[i]; id++) {
      document.getElementById(id.toString()).style.backgroundColor = code_selected;
    };
    
    document.annotationsCreated++;
    Shiny.onInputChange('annotations_created', document.annotationsCreated);
    Shiny.onInputChange('annotations_table', document.annotations);

    if (window.getSelection().empty) {  // Chrome
      window.getSelection().empty();
    } else if (window.getSelection().removeAllRanges) {  // Firefox
      window.getSelection().removeAllRanges();
    }
  }
)
