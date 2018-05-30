"use strict";

function Cube(element) {
  this.wrapper = this._getWrapper(element);
  this.input = this.wrapper ? this.wrapper.querySelector(".cube-input") : null;
}

Cube.prototype = {
  // Private
  _getWrapper: function(element) {
    if (element) {
      return element.closest("[data-object~=cube-wrapper]");
    } else {
      return null;
    }
  },

  get _faceWrappers() {
    return this.wrapper.querySelectorAll("[data-object~=face-wrapper]");
  },

  _positionChanged: function() {
    return this.position !== this.positionOriginal;
  },

  _textChanged: function() {
    return this.text !== this.textOriginal;
  },

  _destroy: function() {
    this.wrapper = null;
    this.input = null;
  },

  // Public
  get faces() {
    var that = this;
    return Array.prototype.map.call(this._faceWrappers, function(element) {
      return new Face(element, that);
    });
  },

  get id() {
    return this.wrapper.getAttribute("data-cube") || null;
  },

  set id(val) {
    this.wrapper.setAttribute("data-cube", val);
  },

  get position() {
    return parseInt(this.wrapper.getAttribute("data-position"));
  },

  set position(val) {
    this.wrapper.setAttribute("data-position", val);
  },

  get positionOriginal() {
    return parseInt(this.wrapper.getAttribute("data-position-original"));
  },

  set positionOriginal(val) {
    this.wrapper.setAttribute("data-position-original", val);
  },

  get text() {
    return this.input.value;
  },

  set text(val) {
    this.input.value = val;
  },

  get textOriginal() {
    return this.wrapper.getAttribute("data-text-original");
  },

  set textOriginal(val) {
    this.wrapper.setAttribute("data-text-original", val);
  },

  get cubeType() {
    return this.wrapper.getAttribute("data-cube-type");
  },

  set cubeType(val) {
    this.wrapper.setAttribute("data-cube-type", val);
  },

  get url() {
    return this.wrapper.getAttribute("data-url");
  },

  get saving() {
    return this.wrapper.getAttribute("data-saving") === "true";
  },

  set saving(val) {
    this.wrapper.setAttribute("data-saving", val);
  },

  get destroyed() {
    return this.wrapper.getAttribute("data-destroyed") === "true";
  },

  set destroyed(val) {
    this.wrapper.setAttribute("data-destroyed", val);
  },

  // Returns next cube or null
  get nextCube() {
    var next = new Cube(this.wrapper.nextElementSibling);
    return (next.wrapper ? next : null);
  },

  // Returns prev cube or null
  get prevCube() {
    var prev = new Cube(this.wrapper.previousElementSibling);
    return (prev.wrapper ? prev : null);
  },

  // This function should draw all attributes to their visible locations and set
  // the appropriate class/es for the cube.
  redraw: function() {
    this.redrawText();
    this.redrawPosition();
    // this.redrawCubeType(); // TODO: Check if this should be redrawn as well.
  },

  redrawPosition: function() {
    // console.log("redrawPosition()");
    this.wrapper.querySelector(".cube-id").innerHTML = "<small>#" + (this.id || "Ø") + "</small> " + this.position;
    if (this._positionChanged()) {
      this.wrapper.classList.add("cube-wrapper-unsaved-position");
    } else {
      this.wrapper.classList.remove("cube-wrapper-unsaved-position");
    }
  },

  // This does not modify input.value with "text original".
  redrawText: function() {
    // console.log("redrawText()");
    if (this._textChanged()) {
      this.wrapper.classList.add("cube-wrapper-unsaved");
    } else {
      this.wrapper.classList.remove("cube-wrapper-unsaved");
    }
  },

  redrawCubeType: function() {
    // console.log("redrawCubeType()");
    var cube_type = this.wrapper.querySelector(".cube-type");
    cube_type.replaceWith(Cube._template_cube_type(this.cubeType));
  },

  appendCube: function(text) {
    if (text == null) text = "";
    var element = this._template(text);
    this.wrapper.insertAfter(element);
    return element; // TODO: Make this return a cube object.
  },

  appendFace: function(element, text) {
    if (text == null) text = "";
    // console.log("cube.appendFace();");
    var face = new Face(element, this);
    var node = face.appendFace(text);
    this.updateFacePositions(face.position);
    this.saveFacePositions(face.position);
    return node;
  },

  appendNewFaceToCubeWrapper: function(text, position) {
    if (text == null) text = "";
    if (position == null) position = 1;
    // console.log("cube.appendNewFaceToCubeWrapper();");
    var newElement = Face._template(
      text,
      position,
      this.url + "/" + this.id + "/faces",
      this.wrapper.getAttribute("data-tray"),
      this.id
    );
    this.wrapper.querySelector(".cube-faces").appendChild(newElement);
  },

  updateFacePositions: function(start) {
    // console.log("cube.updateFacePositions();");
    if (start == null) start = 0;
    this.faces.slice(start).forEach(function(face, index) {
      face.position = start + index + 1;
      face.redrawPosition();
    });
  },

  changed: function() {
    return (this._positionChanged() || this._textChanged());
  },

  unchanged: function() {
    return !this.changed();
  },

  // Returns true if cubeType is "choice".
  hasFaces: function() {
    return (this.cubeType == "choice");
  },

  removeFromDOM: function() {
    // console.log("removeFromDOM()");
    this.wrapper.remove();
    this._destroy();
  },

  remove: function() {
    if (this.text) return;
    var position = this.position - 1; // Needs to be stored before cube is destroyed/removed.
    this.destroy();
    this.removeFromDOM();
    var tray = new Tray();
    tray.updateCubePositions(position); // Needs to be done after cube is removed from DOM.
    tray.saveCubePositions();
  },

  focusPreviousAndDelete: function() {
    this.destroyed = "true"; // Make sure cube isn't saved on input blur.
    if (this.prevCube) this.prevCube.focusEnd();
    this.remove();
  },

  focusNextAndDelete: function() {
    this.destroyed = "true"; // Make sure cube isn't saved on input blur.
    if (this.nextCube) this.nextCube.focusStart();
    this.remove();
  },

  focusFirstChild: function() {
    var face = this.faces[0];
    if (face && face.input) setFocusEnd(face.input);
  },

  focusLastChild: function() {
    var face = this.faces[this.faces.length - 1];
    if (face && face.input) setFocusEnd(face.input);
  },

  focusEnd: function() {
    if (this.input) setFocusEnd(this.input);
  },

  focusStart: function() {
    if (this.input) setFocusStart(this.input);
  }
};
