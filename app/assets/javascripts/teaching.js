var lastDfnTime = new Date(); 

$(document).ready(function () {  

    document.addEventListener("selectionchange", function () {
        console.log("selectionchange event caught")

        // Search for the pageDisplay div, if found then send off the request.  
        div = document.getElementById("pageDisplayArea"); 
        now = new Date(); 
        console.log("time diff" + (now - lastDfnTime))
        if (div != null && now - lastDfnTime > 3000) {
            define(); 
        } else {
            console.log("Could not find pageDisplayArea div, event ignored."); 
        }

    }, false);
        
});

function define() {
    searchString = getSelectionText();
    if (searchString.length > 1 && searchString.length < 35) {
        console.log("Requesting definition for text: " + searchString)
        $.ajax({
            url: 'teaching/define',
            data: { searchString: searchString },
            type: 'GET',
            dataType: 'json',
                
            success: function (data, textStatus, jqXHR) {
                if (data.definition != "") {
                    stringToDisplay = data.title + ": "
                    stringToDisplay = stringToDisplay + data.definition
                    if (data.example) {
                        stringToDisplay = stringToDisplay + "\n\nExample: " + data.example
                    }
                    window.alert(stringToDisplay)
                    // Clear the selection set the new time flag
                    clearSelection();
                    lastDfnTime = new Date(); 

                } else {
                    console.log("Request returned with nil definition.")
                }
            },
                
            error: function (jqXHR, textStatus, errorThrown) {
                console.log("AJAX error: #{textStatus}")
            }
        })
    }
}

function clearSelection() {
    if (window.getSelection) window.getSelection().removeAllRanges();
    else if (document.selection) document.selection.empty();
}

function sayHello() { window.alert("Hello!") }; 

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

function toggleToNextImage(current, next) {
    nextElem = document.getElementById(next); 
    current.style.display = 'none'
    nextElem.style.display = 'inline'
}