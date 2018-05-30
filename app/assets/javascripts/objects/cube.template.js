"use strict";

Cube._template_cube_input = function(text) {
  var cube_input = document.createElement("INPUT");
  cube_input.classList.add("cube-input");
  cube_input.setAttribute("autocomplete", "off");
  cube_input.setAttribute("placeholder", document.getElementById("language").getAttribute("data-enter-question-placeholder"));
  cube_input.setAttribute("type", "text");
  cube_input.setAttribute("value", text);
  return cube_input;
};

Cube._template_cube_type = function(type) {
  if (type == null) type = "string";
  var small_link = document.createElement("SMALL");
  var cube_type_link = document.createElement("A");
  var cube_type_link_text = document.createTextNode(type);
  cube_type_link.setAttribute("data-object", "cube-details-clicker");
  cube_type_link.setAttribute("href", "#");
  cube_type_link.setAttribute("tabindex", "-1");
  cube_type_link.appendChild(cube_type_link_text);
  small_link.appendChild(cube_type_link);
  var cube_type = document.createElement("DIV");
  cube_type.classList.add("cube-type");
  cube_type.appendChild(small_link);
  return cube_type;
};

Cube._template_cube_info = function(position) {
  var small_id = document.createElement("SMALL");
  var text_id = document.createTextNode(" #Ø");
  small_id.appendChild(text_id);
  var text_position = document.createTextNode("" + position);
  var cube_info = document.createElement("DIV");
  cube_info.classList.add("cube-id");
  cube_info.appendChild(small_id);
  cube_info.appendChild(text_position);
  return cube_info;
};

Cube._template_cube_div = function(text, type, position) {
  var cube_input = this._template_cube_input(text);
  var cube_type = this._template_cube_type(type);
  var cube_info = this._template_cube_info(position);
  var cube_div = document.createElement("DIV");
  cube_div.classList.add("cube");
  cube_div.appendChild(cube_input);
  cube_div.appendChild(cube_type);
  cube_div.appendChild(cube_info);
  return cube_div;
};

Cube._template_cube_faces = function() {
  var cube_faces = document.createElement("DIV");
  cube_faces.classList.add("cube-faces");
  return cube_faces;
};

Cube._template = function(text, type, position, url, tray) {
  var cube_div = Cube._template_cube_div(text, type, position);
  var cube_faces = Cube._template_cube_faces();
  var element = document.createElement("DIV");
  element.classList.add("cube-wrapper"); // IE11 compatibility, add class one at a time: https://caniuse.com/#search=classList
  element.classList.add("cube-wrapper-unsaved");
  element.setAttribute("data-object", "cube-wrapper");
  element.setAttribute("data-cube-type", type);
  element.setAttribute("data-position", position);
  element.setAttribute("data-url", url);
  element.setAttribute("data-tray", tray); // TODO: Remove?
  element.appendChild(cube_div);
  element.appendChild(cube_faces);
  return element;
};

Cube.prototype._template = function(text, type) {
  if (text == null) text = "";
  if (type == null) type = "string";
  return Cube._template(
    text,
    type,
    this.position + 1,
    this.wrapper.getAttribute("data-url"),
    this.wrapper.getAttribute("data-tray")
  );
};
