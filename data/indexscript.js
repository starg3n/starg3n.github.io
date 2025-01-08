htm = ".html"
function goToPage(e) {
  let url="https://starg3n.github.io/"+e.+".html";  
  console.log(url);
  window.location = url;
}

// all this script does is make a textbox that when data is inputted, it adds it to the url.
//
// example:
// >index
// would take you to starg3n.github.io/index.html
//
// this was very simple, and I (or you) could use it to password protect your site
// as in your index page JUST contains a textbox
// and you have to put in the right number combo? words? that takes you to the REAL homepage.
//
// this was pilfered from stack overflow
// https://stackoverflow.com/questions/54991362/use-text-box-to-go-to-a-specific-page
