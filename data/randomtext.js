// to be honest this is stolen from stack overflow just like indexscript.js, don't judge me pls

const textSelect= [ // our table
    '1',
    '2',
    '3',
];
 
function getRandomText() {
    const randomIndex = Math.floor(Math.random() * textSelect.length); //do some math 
    return textSelect[randomIndex];
  }
 
function loadText() {
  const myDiv = document.getElementById('phrase'); // find an html element with the "phrase" id in it
  myDiv.innerHTML= getRandomText(); // load our random text into this element
}
 
window.onload = loadText; // load in our text when the window loads

//example: <p id="phrase"></p>
// this works with any text :D