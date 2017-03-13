$("#pageDisplayArea").click(function() {
    searchString = getSelectionText();
    if (searchString != " " && searchString != "") {
        console.log("Requesting definition for text: " + searchString)
        $.ajax({
                url: 'teaching/define',
                data: { searchString: searchString },
                type: 'GET',
                dataType: 'json',
                
                success: function(data, textStatus, jqXHR) {
                    if (data.definition != "") {
                        stringToDisplay = data.title + ":\n"
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
}) 

// $("#pageDisplayArea").click( function () { window.alert('ss')} );



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

// var textHasJustBeenDefined = false;

// Function to toggle detail image for the container given by imageFrame.
// Note a strict naming pattern is required to make this function work - topic name, followed by level number, followed by page, followed by image number and either a or b (a for high-level, b for detail). Eg, The Shoulder JointL2P3Image1a

function toggleImage(imageFrame) {
    var currentImageSource = imageFrame.src
    var currentImageAlt = imageFrame.alt
    var index = currentImageSource.lastIndexOf("/")
    var rootForNextImage = currentImageSource.slice(index)
    var currentImage = currentImageSource.slice(-5)
    if (currentImage == "a.png") {
        rootForNextImage = rootForNextImage.replace("a.png", "b.png")
        imageFrame.src = 'images/' + rootForNextImage.substring(1)
    } else {
        rootForNextImage = rootForNextImage.replace("b.png", "a.png")
        imageFrame.src = 'images/' + rootForNextImage.substring(1)
    }
}

