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
// require turbolinks
//
//= require jquery
//= require jquery_ujs
//= require imagerotator.js
//= require_tree . 

// ================================= PAGE LOAD METHODS ================================================

// When page first loads at the site root, assume no touch until proven otherwise. 
window.USER_IS_TOUCHING = false; 
window.EVENT_NAME = 'mouseup'; 

window.addEventListener('touchstart', function onFirstTouch() {

      // Global to hold the state. 
      window.USER_IS_TOUCHING = true;
      window.EVENT_NAME = 'touchend'; 

      // Can stop listening now we have a touch
      console.log("Touch detected, swapping event listeners")
      window.removeEventListener('touchstart', onFirstTouch, false);
   }, false);


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