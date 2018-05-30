"use strict";

Cube.paste = function(event) {
  var array = Cube._pastedTextToArray(event);
  if (!array) return;
  var element = event.target;
  if (array.length === 1 || element.value === "") insertTextAtCursor(element, array.shift());
  var tray = new Tray();
  var nextElement = element;
  var multiline = false;
  var facePosition = 0;
  array.forEach(function(text) {
    var cube;
    var currentElement = nextElement;
    if (text[0] === "-") {
      cube = new Cube(nextElement);
      if (facePosition === 0) {
        cube.cubeType = "choice";
        cube.redrawCubeType();
      }
      facePosition += 1;
      cube.appendNewFaceToCubeWrapper(text.slice(1).trim(), facePosition);
    } else {
      nextElement = tray.appendCube(nextElement, text);
      facePosition = 0;
    }
    multiline = true;
    // Save last cube if facePosition == 0
    if (facePosition === 0) {
      cube = new Cube(currentElement);
      cube.save("paste");
    }
  });
  if (multiline) {
    // Save last cube
    var cube = new Cube(nextElement);
    cube.save("paste");
    nextElement = tray.appendCube(nextElement);
    cube = new Cube(nextElement);
    cube.focusEnd();
  }
  event.preventDefault();
};

Cube._pastedTextToArray = function(event) {
  var pastedText = Cube._pastedText(event);
  if (!pastedText) return;
  var array = pastedText.split("\n").map(function(x) { return x.trim(); }).filter(function(x) { return x.length > 0; });
  return array;
};

Cube._pastedText = function(event) {
  var pastedText;
  if (window.clipboardData && window.clipboardData.getData) { // IE
    pastedText = window.clipboardData.getData("Text");
  } else {
    var clipboardData = (event.originalEvent || event).clipboardData;
    if (clipboardData && clipboardData.getData) pastedText = clipboardData.getData("text/plain");
  }
  return pastedText;
};
