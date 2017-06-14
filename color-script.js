function ran_col() { //function name
  var hue = Math.floor(Math.random() * 360);
  var pastel = 'hsl(' + hue + ', 100%, 87.5%)';
  document.getElementById('mybody').style.background = pastel; // Setting the random color on your div element.
}
