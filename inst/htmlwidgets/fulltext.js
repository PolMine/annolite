HTMLWidgets.widget({
  
  name: "fulltext",
  
  type: "output",
  
  factory: function(el, width, height) {
    
    var getSelectionText; // needs to be defined globally

    return {
      renderValue: function(x) {
        
        window.annotation_color = "yellow";
        
        document.getElementsByTagName("body")[0].style.overflow = "scroll";

        var div = document.getElementsByClassName("fulltext")[0];
        div.style.overflow = "scroll";
        div.style.border = "1px solid #ddd";
        div.style.padding = "5px";

        for (var i = 0; i < x.data.length; i++){
            p = x.data[i].tokenstream;
            newPara = "<" + x.data[i].element + ">";
            for (var j = 0; j < p.token.length; j++){
              newPara = newPara + '<span id="' + p.cpos[j] + '">' + p.token[j] + '</span> ';
            }
            newPara = newPara + "</" + x.data[i].element + ">";
            div.innerHTML = div.innerHTML + newPara;
        }
        
        function getSelectionText() {
          var text = "";
          if (window.getSelection) {
            var highlighted_text = window.getSelection().toString()
            var cpos_left = parseInt(window.getSelection().anchorNode.parentNode.getAttribute("id"));
            var cpos_right = parseInt(window.getSelection().focusNode.parentNode.getAttribute("id"));
            
            var code_color = bootbox.prompt({
              title: 'Add Annotation\
                      <hr/>\
                      <div id="selection" class="btn-group" data-toggle="buttons">\
                      <label class="radio-inline">\
                        <input type="radio" name="optradio" checked value="yellow">keep\
                      </label>\
                      <label class="radio-inline">\
                        <input type="radio" name="optradio" value="lightgreen">reconsider\
                      </label>\
                      <label class="radio-inline">\
                        <input type="radio" name="optradio" value="lightgrey">drop\
                      </label>\
                      </div>',
              inputType: 'textarea',
              callback: function (result) {
                var code_selected = $('#selection input:radio:checked').val();
                for (var cpos = cpos_left; cpos <= cpos_right; cpos++) {
                  var spanEl = document.getElementById(cpos.toString());
                  spanEl.style.backgroundColor = code_selected;
                }
                Shiny.onInputChange('code', code_selected);
                Shiny.onInputChange('annotation', result);
                Shiny.onInputChange('region', [cpos_left, cpos_right]);
                console.log(window.getSelection().toString());
                Shiny.onInputChange('text', highlighted_text);
            
                if (window.getSelection().empty) {  // Chrome
                  window.getSelection().empty();
                } else if (window.getSelection().removeAllRanges) {  // Firefox
                  window.getSelection().removeAllRanges();
                }
              }
            });

            
          } else if (document.selection && document.selection.type != "Control") {
            text = document.selection.createRange().text;
            
          }
          
        }
        
        div.onmouseup = function() { getSelectionText(); };

      },
      
      resize: function(width, height) {
      }
    };
  }
});