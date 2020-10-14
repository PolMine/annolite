HTMLWidgets.widget({
  
  name: "fulltext",
  
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
                callback: x.settings.callbackFunction
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