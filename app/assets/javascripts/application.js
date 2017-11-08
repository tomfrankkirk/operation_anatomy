// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require imagerotator.js
//= require jquery-1.8.3.min.js
//= require_tree . 



// ================================= PAGE LOAD METHODS ================================================

// When page first loads at the site root, attach the wrapper function to selection change events. 
$(document).ready( function() {
   document.addEventListener('selectionchange', defineWrapper); 
})


// ================================= DEFINE METHODS ===================================================

// Wrapper function for define functionality. Only passes through if the pageDisplayArea div is present
// on the current page. 
function defineWrapper() { 
   if (document.getElementById("pageDisplayArea")) {
      console.log("Teaching page! Respond"); 
      define();      

   } else {
      console.log("Not a teaching page.");    
   }
} 

// Main define function. Fetches the current selection, filters to make sure that it is non-trivial (ie, they
// did not select a single char or equally a huge passage) and then requests a definition. Upon successful response
// the selection is cleared via a call to clearSelection(). 
function define() {
   
   // Get the selection. 
    searchString = getSelectionText();

    // Is this non-trivial?
    if (searchString.length > 1 && searchString.length < 35) {
        console.log("Requesting definition for text: " + searchString)
        $.ajax({
            url: 'teaching/define',
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


// ================================= IMAGE METHODS ===================================================

// Switch images if present. 
function toggleToNextImage(current, next) {
    nextElem = document.getElementById(next); 
    current.style.display = 'none'
    nextElem.style.display = 'inline'
}