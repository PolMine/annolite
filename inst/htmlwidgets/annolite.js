HTMLWidgets.widget({
  
  name: "annolite",
  
  type: "output",
  
  factory: function(el, width, height) {
    
    el.style.overflow = "scroll";
    el.style.padding = "5px";

    var container = el;
    
    document.annotations = {};
    document.annotationsChanged = 0;
    var getSelectionText; // needs to be defined globally
    var textSelected;
    var annotationCompleted;

    var selected_subcorpus;
    var previously_selected_subcorpus;
    var tokens;
    var from;
    var to;
    var range;
    
    // instantiate handles only if crosstalk is available
    if (typeof crosstalk != "undefined"){
    
      var ct_sel = new crosstalk.SelectionHandle();
      ct_sel.on("change", function(e) {
        tokens = document.getElementsByName(previously_selected_subcorpus);
        tokens.forEach((token) => {token.style.display = "none";});
        previously_selected_subcorpus = e.value;
      
        tokens = document.getElementsByName(e.value);
        tokens.forEach((token) => {token.style.display = "block";});

      });
    
      var ct_filter = new crosstalk.FilterHandle();
      ct_filter.on("change", function(e) {
        tokens = document.getElementsByName(previously_selected_subcorpus);
        tokens.forEach((token) => { token.style.display = "none"; });
        previously_selected_subcorpus = ct_filter.filteredKeys;
      
        console.log("ct_filter.filteredKeys");
        tokens = document.getElementsByName(ct_filter.filteredKeys);
        tokens.forEach((token) => { token.style.display = "block";});
      });
    }



    return {
      renderValue: function(x) {
        
        if (x.settings.box){ container.style.border = "1px solid #ddd"; }
        
        if (x.settings.crosstalk){
          ct_filter.setGroup(x.settings.crosstalk_group);
          ct_sel.setGroup(x.settings.crosstalk_group);
        }
        
        if (x.settings.buttons){
          var buttons = 'Add Annotation<hr/><div id="selection" class="btn-group" data-toggle="buttons">';
          for (var i = 0; i < Object.keys(x.settings.buttons).length; i++){
            buttons += '<label class="radio-inline"><input type="radio" name="radioGroup" value="';
            buttons += x.settings.buttons[Object.keys(x.settings.buttons)[i]];
            buttons += '"';
            if (i === 0) buttons += ' checked';
            buttons += '>';
            buttons += Object.keys(x.settings.buttons)[i] + '</label>';
          }
          buttons += '</div>';
        }

        container.innerHTML += x.data.fulltext;

        document.annotations = x.data.annotations;

        for (var i = 0; i < x.data.annotations.start.length; i++){
          for (var id = x.data.annotations.start[i]; id <= x.data.annotations.end[i]; id++){
            var token = document.getElementById(id.toString());
            token.style.backgroundColor = x.data.annotations.color[i];
            
            token.setAttribute("data-toggle", "tooltip");
            token.setAttribute("data-placement", "auto top");
            var tooltipText = x.data.annotations.code[i];
            if (!RegExp("^\\s*$").test(x.data.annotations.annotation[i])){
                tooltipText = tooltipText + '<br><i>[' + x.data.annotations.annotation[i] + ']</i>'
            }
            token.setAttribute("title", tooltipText);
            $('#' + id).tooltip({html: true});

            if (x.settings.buttons){
              token.addEventListener('contextmenu', function(ev) {
                ev.preventDefault();
                return false;
              }, true);
            }
          }
        }
        
        function bootboxCallback(result) {
          
          // Simply checking for result will not do because result = "" will be treated as false
          if (result !== null){
            
            var colorSelected = $('#selection input:radio:checked').val();
            var codeSelected = $('input[name="radioGroup"]:checked').parent().text();
            
            document.annotations.start.push(range[0]);
            document.annotations.end.push(range[1]);
            document.annotations.text.push(textSelected);
            document.annotations.code.push(codeSelected);
            document.annotations.color.push(colorSelected);
            document.annotations.annotation.push(result);
            
            for (var id = range[0]; id <= range[1]; id++) {
              var token = document.getElementById(id.toString());
              token.style.backgroundColor = colorSelected;
              token.setAttribute("data-toggle", "tooltip");
              token.setAttribute("data-placement", "auto top");
              var tooltipText = codeSelected;
              if (!RegExp("^\\s*$").test(result)){
                tooltipText += '<br><i>[' + result + ']</i>';
              }
              token.setAttribute("title", tooltipText);
              $('#' + id).tooltip({html: true});
            }
    
            document.annotationsChanged++;
            Shiny.onInputChange('annotations_changed', document.annotationsChanged);
            Shiny.onInputChange('annotations_table', document.annotations);

          }
    
          if (window.getSelection().empty) {  // Chrome
            window.getSelection().empty();
          } else if (window.getSelection().removeAllRanges) {  // Firefox
            window.getSelection().removeAllRanges();
          }
        }
        
        function deleteAnnotationCallback(result){
          // With bootbox.confirm, 'result' will be true ("OK") or false (cancel)
          if (result){
            var index = 0;
            for (index = 0; index <= document.annotations.start.length - 1; index++){
              if (
                (range[0] >= document.annotations.start[index]) && 
                (range[0] <= document.annotations.end[index])
              ){
                // Remove highlight and tooltip
                for (var id = document.annotations.start[index]; id <= document.annotations.end[index]; id++){
                  
                  var token = document.getElementById(id.toString());
                  token.style.backgroundColor = "";
                  $('#' + id).tooltip("disable");
                  token.removeAttribute("data-toggle");
                  token.removeAttribute("data-placement");
                  token.removeAttribute("title");
                }
                
                // Remove annotation
                for (const [key, value] of Object.entries(document.annotations)){
                  document.annotations[key].splice(index, 1);
                }
              }
              
              // Send message to R/Shiny that annotations have changed and transfer new data
              document.annotationsChanged++;
              Shiny.onInputChange('annotations_changed', document.annotationsChanged);
              Shiny.onInputChange('annotations_table', document.annotations);
            }
          }
        }

        
        function getSelectionText() {
          var text = "";
          if (window.getSelection) {
            
            var anchorParent = window.getSelection().anchorNode.parentNode;
            var focusParent = window.getSelection().focusNode.parentNode;
            textSelected = window.getSelection().toString();

            if (RegExp("^\\s+$").test(textSelected)){
              console.log("nothing selected");
            } else {

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
              
              
              // If the annotation has been generated against the direction of reading
              // (right to left), the end position will be smaller than the start
              // position - assign start and end accordingly
              if (end >= start){
                range = [start, end]
              } else {
                range = [end, start]
              }
              
              // Iterate through tokens and test whether any is highlighted
              var isHighlighted = false;
              for (var id = range[0]; id <= range[1]; id++){
                var annocolor = document.getElementById(id.toString()).style.backgroundColor;
                if (!RegExp("^\\s*$").test(annocolor)) isHighlighted = true;
              };

              if (!isHighlighted){
                bootbox.prompt({
                  title: buttons,
                  inputType: 'textarea',
                  callback: bootboxCallback
                });
                
              } else {
                
                if ((range[1] - range[0]) == 0){
                  console.log("one token only");
                  
                  bootbox.confirm({
                    message: "Delete Annotation?",
                    callback: deleteAnnotationCallback
                  });
                } else {
                  bootbox.alert({
                    message: 'Existing annotation in selection:</br>Select only one token of existing annotation to delete it!',
                    size: 'small'
                  });
                }
              }

            };
          } else if (document.selection && document.selection.type != "Control") {
            text = document.selection.createRange().text;
          }
          
        }
        
        if (x.settings.buttons){
          container.onmouseup = function(el) { getSelectionText() };
        };

      },
      
      resize: function(width, height) {
      }
    };
  }
});