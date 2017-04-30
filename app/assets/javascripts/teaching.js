function define() {
    searchString = getSelectionText();
    if (searchString.length > 1 && searchString.length < 35) {
        console.log("Requesting definition for text: " + searchString)
        $.ajax({
                url: 'teaching/define',
                data: { searchString: searchString },
                type: 'GET',
                dataType: 'json',
                
                success: function(data, textStatus, jqXHR) {
                    if (data.definition != "") {
                        stringToDisplay = data.title + ": "
                        stringToDisplay = stringToDisplay + data.definition
                        if (data.example) {
                            stringToDisplay = stringToDisplay + "\n\nExample: " + data.example
                        }
                        window.alert(stringToDisplay)
                    } else {
                        console.log("Request returned with nil definition.")
                    }
                    data = null; 
                },
                
                error: function(jqXHR, textStatus, errorThrown) {
                    console.log("AJAX error: #{textStatus}")
                }
        })
    }
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