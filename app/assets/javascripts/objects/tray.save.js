"use strict";

Tray.prototype.saveCubePositions = function() {
  // console.log("tray.saveCubePositions();");
  var url = "";
  var params = {};
  params.cubes = {};

  this.cubes.forEach(function(cube, index) {
    if (!cube._positionChanged()) return true; // TODO: Change calling of "private" method?
    url = cube.url + "/positions"; // TODO: Change to tray.url? currently is "/trays/1/cubes/positions.json"
    params.cubes[cube.id] = { "position": cube.position };
  });

  // console.log(params);
  if (!url) return;

  Fridge.post(url, params, this._saveCubePositionsDone, this._saveCubePositionsFail);
};

Tray.prototype._saveCubePositionsDone = function(request) {
  var data = JSON.parse(request.responseText);
  if (data != null) {
    data.forEach(function(datum) {
      var element = document.querySelector("[data-object~=\"cube-wrapper\"][data-cube=\"" + datum.id + "\"]");
      var cube = new Cube(element);
      if (cube.wrapper) {
        cube.positionOriginal = datum.position;
        cube.redrawPosition();
      } else {
        console.error("Cube #" + datum.id + " not found.");
      }
    });
  }
};

Tray.prototype._saveCubePositionsFail = function(request) {
  console.error(request);
};
