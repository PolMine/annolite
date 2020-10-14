HTMLWidgets.widget({
  
  name: "annotator",
  
  type: "output",
  
  factory: function(el, width, height) {
    
    document.annotations = {};
    document.annotationsCreated = 0;
    var getSelectionText; // needs to be defined globally
    var annotationCompleted;
    
    el.style.overflow = "scroll";
    el.style.padding = "5px";
    var container = el;
    
    

    return {
      renderValue: function(x) {
        
        document.annotations = x.data.annotations;
        if (x.settings.box){ container.style.border = "1px solid #ddd"; };


        for (var i = 0; i < x.data.paragraphs.length; i++){
            p = x.data.paragraphs[i].tokenstream;
            newPara = "<" + x.data.paragraphs[i].element + ">";
            for (var j = 0; j < p.token.length; j++){
              newPara = newPara + '<span>' + p.whitespace[j] + '</span>' + '<span id="' + p.id[j] + '">' + p.token[j] + '</span>';
            }
            newPara = newPara + "</" + x.data.paragraphs[i].element + ">";
            container.innerHTML = container.innerHTML + newPara;
        };
        
        for (var i = 0; i < x.data.annotations.start.length; i++){
          for (var id = x.data.annotations.start[i]; id <= x.data.annotations.end[i]; id++){
            el = document.getElementById(id.toString())
            el.style.backgroundColor = x.data.annotations.color[i];
            el.addEventListener('contextmenu', function(ev) {
              ev.preventDefault();
              alert('success!');
              return false;
            }, true);
          };
        };
        
        function bootboxCallback(result) {
    
          console.log(result);
    
          if (result == null){
      
            console.log("cancelled");
            // remove data that has been added by even handler
            document.annotations.text.pop();
            document.annotations.start.pop();
            document.annotations.end.pop();

          } else {
      
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

        
        function getSelectionText() {
          var text = "";
          if (window.getSelection) {
            
            var anchorParent = window.getSelection().anchorNode.parentNode;
            var focusParent = window.getSelection().focusNode.parentNode;
            var textSelected = window.getSelection().toString();
            
            if (RegExp("^\\s+$").test(textSelected)){
              console.log("nothing selected");
            } else {
              
              bootbox.prompt({
                title: x.settings.codeSelection,
                inputType: 'textarea',
                callback: bootboxCallback
              });

              if (anchorParent.hasAttribute("id")){
                var start = parseInt(anchorParent.getAttribute("id"));
              } else {
                var start = parseInt(anchorParent.nextSibling.getAttribute("id"));
              };
              
              if (focusParent.hasAttribute("id")){
                var end = parseInt(focusParent.getAttribute("id"));
              } else {
                var end = parseInt(focusParent.previousSibling.getAttribute("id"));
              };
              
              // code, color and the text of the annotation are added in bootbox
              document.annotations.text.push(textSelected);
              document.annotations.start.push(start);
              document.annotations.end.push(end);

            };
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