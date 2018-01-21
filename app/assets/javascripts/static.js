function defineDemo() {
   var selection = getSelectionText(); 
   var title = 'Aorta'; 
   var defn = 'the largest artery in the body, arising from the outflow tract of the left ventricle.';
   
   if (selection.length < 10 && selection.includes('aorta')) {
      stringToDisplay = title + ": ";
      stringToDisplay = stringToDisplay + defn; // + '\n\n Neat hey?';
      window.alert(stringToDisplay); 
      clearSelection();
   }
}