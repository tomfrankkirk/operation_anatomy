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

window.addEventListener("turbolinks:load", function(event) {
   console.log('Turbolinks:load');
   if (document.getElementById("pageDisplayArea")) {
      console.log("Teaching page, attaching listener");  
      document.addEventListener("selectionchange", define); 

   } else {
      console.log("Not a teaching page, detach listeners");   
      document.removeEventListener("selectionchange", define) 
   }
});

function sayHello() {
   window.alert("Hello there!"); 
} 

// =============================== SHOW/HIDE METHODS =============================++==================
   
function showHideDiv(parent) {
   // $(parent).toggleClass('special');
   d = parent.querySelector('.showHideDiv')
   if (d.style.display == 'none' || d.style.display == '') {
         d.style.display = 'block'
      } else {
         d.style.display = 'none'
    }
}


// ================================= IMAGE METHODS ===================================================

// Switch images if present. 
function toggleToNextImage(current, next) {
    nextElem = document.getElementById(next); 
    current.style.display = 'none'
    nextElem.style.display = 'inline'
}