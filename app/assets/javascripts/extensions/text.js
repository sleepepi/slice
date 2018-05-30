"use strict";

function boldSelection(element) {
  var start = element.selectionStart;
  var end = element.selectionEnd;
  var length = end - start;
  var text = element.value.substr(start, length);

  if (text.trim()) {
    var padding_start = (text[0] == " ");
    var padding_end = (text[text.length - 1] == " ");
    var substitute = "";
    if (padding_start) substitute += " ";
    substitute += "**";
    substitute += text.trim();
    substitute += "**";
    if (padding_end) substitute += " ";
    insertTextAtCursor(element, substitute);
  }
}

function nothingSelected(element) {
  var start = element.selectionStart;
  var end = element.selectionEnd;
  return start === end;
}

function insertTextAtCursor(element, text) {
  if (document.execCommand("insertText", false, text)) return;

  // console.log("insertTextAtCursor() fallback (Firefox 59 and Firefox 60)");
  var start = element.selectionStart;
  var position = start + text.length;
  var end = element.selectionEnd;
  var originalText = element.value;
  element.value = originalText.substring(0, start) + text + originalText.substring(end);
  setFocusPosition(element, position);
}
