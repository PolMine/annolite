HTMLWidgets.widget({
  
  name: "fulltext",
  
  type: "output",
  
  factory: function(el, width, height) {
    
    var getSelectionText; // needs to be defined globally
    
    // document.getElementsByTagName("body")[0].style.overflow = "scroll";

    // var div = document.getElementsByClassName("fulltext")[0];
    el.style.overflow = "scroll";
    el.style.padding = "5px";
    var container = el;

    return {
      renderValue: function(x) {
        
        // document.foo = x;
        if (x.settings.box){ container.style.border = "1px solid #ddd"; };


        for (var i = 0; i < x.data.length; i++){
            p = x.data[i].tokenstream;
            newPara = "<" + x.data[i].element + ">";
            for (var j = 0; j < p.token.length; j++){
              newPara = newPara + '<span id="' + p.id[j] + '">' + p.token[j] + '</span> ';
            }
            newPara = newPara + "</" + x.data[i].element + ">";
            container.innerHTML = container.innerHTML + newPara;
        }
        
        function getSelectionText() {
          var text = "";
          if (window.getSelection) {
            window.highlighted_text = window.getSelection().toString()
            window.id_left = parseInt(window.getSelection().anchorNode.parentNode.getAttribute("id"));
            window.id_right = parseInt(window.getSelection().focusNode.parentNode.getAttribute("id"));
            
            var code_color = bootbox.prompt({
              title: x.settings.codeSelection,
              inputType: 'textarea',
              callback: x.settings.callbackFunction
            });

            
          } else if (document.selection && document.selection.type != "Control") {
            text = document.selection.createRange().text;
            
          }
          
        }
        
        if (x.settings.dialog){
          container.onmouseup = function(el) { getSelectionText() };
        };

      },
      
      resize: function(width, height) {
      }
    };
  }
});