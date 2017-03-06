// # function define() {
// #     $.ajax({
// #         url: 'text'
// #         context: document.body
// #         success: function() {
// #             $(document).alert("Success")
// #         }
// #     })
// # }

// define = () -> 
//     window.alert("Hello")
//     $.ajax({
//         url: 'teaching/define'
//         data: { word: 'defineMe' }
//         type: 'GET'
//         dataType: 'json'

//         success: (data, textStatus, jqXHR) -> 
//             window.alert(data.definition)

//         error: (jqXHR, textStatus, errorThrown) -> 
//             console.log("AJAX error: #{textStatus}")
        
//     })

// $ -> 
//     $("button").click (e) -> 
//         e.preventDefault()
//         define()   

//// bind selection change event to my function
// document.ontouchend = selectionEnd();
// document.onmouseup = selectionEnd();

// function userSelectionChanged() {
//     selectionEndTimeout = setTimeout(selectionEnd(), 1000, true);
//     // wait 500 ms after the last selection change event
    
//     if (selectionEndTimeout) {
//         clearTimeout(selectionEndTimeout);
//     }
    
// }

document.addEventListener("selectionchange", selectionEnd, false)

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

function selectionEnd() {
    if (textHasJustBeenDefined) {
        textHasJustBeenDefined = false;
    } else {
        var searchString = getSelectionText();
        if (searchString != " " && searchString != "") {
            console.log("Requesting definition for text: " + searchString)
            $.ajax({
                   url: 'teaching/define',
                   data: { searchString: searchString },
                   type: 'GET',
                   dataType: 'json',
                   
                   success: function(data, textStatus, jqXHR) {
                    if (data.definition != "") {
                        var stringToDisplay = data.title + ":\n"
                        stringToDisplay = stringToDisplay + data.definition
                        if (data.example) {
                            stringToDisplay = stringToDisplay + "\n" + data.example
                        }
                        window.alert(stringToDisplay)
                    } else {
                        console.log("Request returned with nil definition.")
                    }
                   },
                   
                   error: function(jqXHR, textStatus, errorThrown) {
                        console.log("AJAX error: #{textStatus}")
                   }
            })
        }
    }
}

var textHasJustBeenDefined = false;


function toggleDetailForImage(imageFrame) {
    
    // Function to toggle detail image for the container given by imageFrame.
    // Note a strict naming pattern is required to make this function work - topic name, followed by level number, followed by page, followed by image number and either a or b (a for high-level, b for detail). Eg, The Shoulder JointL2P3Image1a
    
    // console.log(idOfImage)
    
    var currentImageSource = imageFrame.src
    var currentImageAlt = imageFrame.alt
    
    var index = currentImageSource.lastIndexOf("/")
    var rootForNextImage = currentImageSource.slice(index)
    //    console.log(rootForNextImage)
    
    var currentImage = currentImageSource.slice(-5)
    //    console.log(currentImage)
    
    if (currentImage == "a.png") {
        rootForNextImage = rootForNextImage.replace("a.png", "b.png")
        imageFrame.src = rootForNextImage.substring(1)
    } else {
        rootForNextImage = rootForNextImage.replace("b.png", "a.png")
        imageFrame.src = rootForNextImage.substring(1)
    }
}

