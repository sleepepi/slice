"use strict";

function Tray() {
  this.wrapper = this._getWrapper();
}

Tray.prototype = {
  // Private
  _getWrapper: function(element) {
    return document.querySelector("[data-object~=tray-wrapper]");
  },

  get _cubeWrappers() {
    return document.querySelectorAll("[data-object~=cube-wrapper]");
  },

  // Public
  get cubes() {
    return Array.prototype.map.call(this._cubeWrappers, function(element) {
      return new Cube(element);
    });
  },

  appendCube: function(element, text) {
    if (text == null) text = "";
    // console.log("appendCube();");
    var cube = new Cube(element);
    var node = cube.appendCube(text);
    this.updateCubePositions(cube.position);
    this.saveCubePositions(cube.position);
    return node;
  },

  updateCubePositions: function(start) {
    if (start == null) start = 0;
    // console.log("tray.updateCubePositions(" + start + ")");
    this.cubes.slice(start).forEach(function(cube, index) {
      cube.position = start + index + 1;
      cube.redrawPosition();
    });
  },
};
