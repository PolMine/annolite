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
            window.highlighted_text = window.getSelection().toString()
            window.cpos_left = parseInt(window.getSelection().anchorNode.parentNode.getAttribute("id"));
            window.cpos_right = parseInt(window.getSelection().focusNode.parentNode.getAttribute("id"));
            
            var code_color = bootbox.prompt({
              title: x.settings.codeSelection,
              inputType: 'textarea',
              callback: x.settings.callbackFunction
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