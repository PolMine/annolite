HTMLWidgets.widget({
  
  name: "fulltext",
  
  type: "output",
  
  factory: function(el, width, height) {
    
    el.style.overflow = "scroll";
    el.style.padding = "5px";
    var container = el;
    var selected_subcorpus;
    var previously_selected_subcorpus;
    var tokens;
    
    var ct_sel = new crosstalk.SelectionHandle();
    ct_sel.on("change", function(e) {
      tokens = document.getElementsByName(previously_selected_subcorpus);
      tokens.forEach((token) => {
        token.style.display = "none";
      })
      previously_selected_subcorpus = e.value;
      
      tokens = document.getElementsByName(e.value);
      tokens.forEach((token) => {
        token.style.display = "block";
      })

    });
    
    var ct_filter = new crosstalk.FilterHandle();
    ct_filter.on("change", function(e) {
      tokens = document.getElementsByName(previously_selected_subcorpus);
      tokens.forEach((token) => { token.style.display = "none"; })
      previously_selected_subcorpus = ct_filter.filteredKeys;
      
      console.log("ct_filter.filteredKeys");
      tokens = document.getElementsByName(ct_filter.filteredKeys);
      tokens.forEach((token) => { token.style.display = "block";})

    });

    return {
      renderValue: function(x) {
        
        ct_filter.setGroup(x.settings.crosstalk_group);
        ct_sel.setGroup(x.settings.crosstalk_group);
        
        // document.annotations = x.data.annotations;
        if (x.settings.box){ container.style.border = "1px solid #ddd"; };
        

        // identical with annotator.js
        for (var i = 0; i < x.data.paragraphs.length; i++){
            var p = "<" + x.data.paragraphs[i].element + " style='" + x.data.paragraphs[i].attributes.style +"' name='" + x.data.paragraphs[i].attributes.name + "'>";
            for (var j = 0; j < x.data.paragraphs[i].tokenstream.token.length; j++){
              p += '<span>' + x.data.paragraphs[i].tokenstream.whitespace[j] + '</span>' + '<span id="' + x.data.paragraphs[i].tokenstream.id[j] + '">' + x.data.paragraphs[i].tokenstream.token[j] + '</span>';
            }
            p += "</" + x.data.paragraphs[i].element + ">";
            container.innerHTML += p;
        };
        
        // identical with annotator.js, but without event listener
        for (var i = 0; i < x.data.annotations.start.length; i++){
          for (var id = x.data.annotations.start[i]; id <= x.data.annotations.end[i]; id++){
            el = document.getElementById(id.toString())
            el.style.backgroundColor = x.data.annotations.color[i];
          };
        };
        
      },
      
      resize: function(width, height) {
      }
    };
  }
});