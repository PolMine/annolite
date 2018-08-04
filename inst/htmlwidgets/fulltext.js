HTMLWidgets.widget({
  
  name: "fulltext",
  
  type: "output",
  
  factory: function(el, width, height) {
    
    return {
      renderValue: function(x) {
        
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
        
      },
      
      resize: function(width, height) {
      }
    };
  }
});