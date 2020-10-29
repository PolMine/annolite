HTMLWidgets.widget({
  
  name: "annolite",
  
  type: "output",
  
  factory: function(el, width, height) {
    
    el.style.overflow = "scroll";
    el.style.padding = "5px";

    var container = el;
    
    document.annotations = {};
    document.annotationsCreated = 0;
    var getSelectionText; // needs to be defined globally
    var annotationCompleted;

    // if (x.settings.crosstalk){
      var selected_subcorpus;
      var previously_selected_subcorpus;
      var tokens;
    
      var ct_sel = new crosstalk.SelectionHandle();
      ct_sel.on("change", function(e) {
        tokens = document.getElementsByName(previously_selected_subcorpus);
        tokens.forEach((token) => {token.style.display = "none";})
        previously_selected_subcorpus = e.value;
      
        tokens = document.getElementsByName(e.value);
        tokens.forEach((token) => {token.style.display = "block";})

      });
    
    // presumably the FilterHandle can be removed:
    // FilterHandle cannot be used due to design
      var ct_filter = new crosstalk.FilterHandle();
      ct_filter.on("change", function(e) {
        tokens = document.getElementsByName(previously_selected_subcorpus);
        tokens.forEach((token) => { token.style.display = "none"; })
        previously_selected_subcorpus = ct_filter.filteredKeys;
      
        console.log("ct_filter.filteredKeys");
        tokens = document.getElementsByName(ct_filter.filteredKeys);
        tokens.forEach((token) => { token.style.display = "block";})
      });
    // }



    return {
      renderValue: function(x) {
        
        if (x.settings.box){ container.style.border = "1px solid #ddd"; };
        
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
            if (i == 0) buttons += ' checked';
            buttons += '>';
            buttons += Object.keys(x.settings.buttons)[i] + '</label>';
          };
          buttons += '</div>';
        }

        container.innerHTML += x.data.fulltext;

        document.annotations = x.data.annotations;

        for (var i = 0; i < x.data.annotations.start.length; i++){
          for (var id = x.data.annotations.start[i]; id <= x.data.annotations.end[i]; id++){
            el = document.getElementById(id.toString())
            el.style.backgroundColor = x.data.annotations.color[i];
            if (x.settings.buttons){
              el.addEventListener('contextmenu', function(ev) {
                ev.preventDefault();
                alert('success!');
                return false;
              }, true);
            }
          };
        };
        
        function bootboxCallback(result) {
    
          if (result == null){
      
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
                title: buttons,
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
        
        if (x.settings.buttons){
          container.onmouseup = function(el) { getSelectionText() };
        };

      },
      
      resize: function(width, height) {
      }
    };
  }
});