function define() {
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

// Function to toggle detail image for the container given by imageFrame.
// Note a strict naming pattern is required to make this function work - topic name, followed by level number, followed by page, followed by image number and either a or b (a for high-level, b for detail). Eg, The Shoulder JointL2P3Image1a

// test ? true : false 


function toggleToNextImage(current, next) {
    nextElem = document.getElementById(next); 
    current.style.display = 'none'
    nextElem.style.display = 'inline'
}






// function toggleImage(imageFrame) {
//     var currentImageSource = imageFrame.src
//     var currentImageAlt = imageFrame.alt
//     var index = currentImageSource.lastIndexOf("/")
//     var rootForNextImage = currentImageSource.slice(index)
//     var currentImage = currentImageSource.slice(-5)
//     if (currentImage == "a.png") {
//         rootForNextImage = rootForNextImage.replace("a.png", "b.png")
//         imageFrame.src = 'images/' + rootForNextImage.substring(1)
//     } else {
//         rootForNextImage = rootForNextImage.replace("b.png", "a.png")
//         imageFrame.src = 'images/' + rootForNextImage.substring(1)
//     }
// }

