// ================================= DEFINE METHODS ===================================================

$(window).on( "load", function() {
   $("#pageDisplayArea").on(window.EVENT_NAME, define);
} );

// Main define function. Fetches the current selection, filters to make sure that it is non-trivial (ie, they
// did not select a single char or equally a huge passage) and then requests a definition. Upon successful response
// the selection is cleared via a call to clearSelection(). 
function define() {
   
// Get the selection. 
   var searchString = getSelectionText();

   // Is this non-trivial?
   if (searchString.length > 1 && searchString.length < 35) {
      console.log("Requesting definition for text: " + searchString)
      $.ajax({
         url: 'dictionary_entries/define',
         data: { searchString: searchString },
         type: 'GET',
         dataType: 'json',
               
         // Response function: if a defn returned, display via alert(). 
         success: function (data, textStatus, jqXHR) {
               if (data.definition != "") {
                  stringToDisplay = data.title + ": "
                  stringToDisplay = stringToDisplay + data.definition
                  if (data.example) {
                     stringToDisplay = stringToDisplay + "\n\nExample: " + data.example; 
                  }
                  window.alert(stringToDisplay); 
                  // Clear the selection
                  clearSelection();
               } else {
                  console.log("Request returned with nil definition."); 
               }
         },
               
         error: function (jqXHR, textStatus, errorThrown) {
               console.log("AJAX error requesting definition:" + textStatus); 
         }
      }); 
   }
}

// Clear the selection from the window. 
function clearSelection() {
    if (window.getSelection) window.getSelection().removeAllRanges();
    else if (document.selection) document.selection.empty();
}

// Get the selection from the window. 
function getSelectionText() {
    var text = "";
    if (window.getSelection) {
        text = window.getSelection().toString();
    } else if (document.selection && document.selection.type != "Control") {
        text = document.selection.createRange().text;
    }
    if (text.length >= 2) {
        return text;
    } else { return ""; }
}

function sayHallo() {
   window.alert("Hallo there!");
} 

// ========================= WR360 methods ==============================
// function initialiseWR360() {
//    console.log('Found WR360 div, preparing'); 
//    var viewer = WR360.ImageRotator.Create("wr360Player"); 
//    viewer.settings.configFileURL = configPath;
//    viewer.runImageRotator(); 
// }