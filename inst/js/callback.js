function (result) {
    
    console.log(result);
    
    if (result == null){
      
      console.log("cancelled");
      // remove data that has been added by even handler
      document.annotations.text.pop();
      document.annotations.start.pop();
      document.annotations.end.pop();

    } else {
      
      console.log("yeah");
      var i = document.annotations.start.length - 1;
      var color_selected = $('#selection input:radio:checked').val();
      var code_selected = $('input[name="radioGroup"]:checked').parent().text();
      document.annotations.code.push(code_selected);
      document.annotations.color.push(color_selected);
      document.annotations.annotation.push(result);
    
      for (var id = document.annotations.start[i]; id <= document.annotations.end[i]; id++) {
        document.getElementById(id.toString()).style.backgroundColor = color_selected;
      };
    
      document.annotationsCreated++;
      Shiny.onInputChange('annotations_created', document.annotationsCreated);
      Shiny.onInputChange('annotations_table', document.annotations);

    };
    
    if (window.getSelection().empty) {  // Chrome
      window.getSelection().empty();
    } else if (window.getSelection().removeAllRanges) {  // Firefox
      window.getSelection().removeAllRanges();
    }
}
