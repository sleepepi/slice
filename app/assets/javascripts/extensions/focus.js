"use strict";

function setFocusEnd(element) {
  setFocusPosition(element, element.value.length);
}

function setFocusStart(element) {
  setFocusPosition(element, 0);
}

function setFocusPosition(element, position) {
  element.focus();
  element.setSelectionRange(position, position);
}
