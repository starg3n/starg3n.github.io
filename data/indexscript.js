function goToPage(e) {
  let url="http://www.exampledomain.com/"+e.target.value+e.html;  
  console.log(url);
  window.location = url;
}
