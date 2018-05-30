"use strict";

Cube.prototype._saveDone = function(request, event_type) {
  var data = JSON.parse(request.responseText);
  if (data != null) {
    this.positionOriginal = data.position;
    this.id = data.id;
    this.textOriginal = data.text;
    this.text = data.text;
    this.saving = "false";
    this.redraw();
    if (event_type == "blur") {
      var tray = new Tray();
      tray.saveCubePositions();
    }
    if (event_type == "paste") {
      this.faces.forEach(function(face) {
        face.save(event_type);
      });
      this.saveFacePositions(); // TODO: Check if saveFacePositions is needed here.
    }
  }
};

Cube.prototype._saveFail = function(request) {
  this.saving = "false";
  console.error(request);
};

Cube.prototype.save = function(event_type) {
  if (this.unchanged()) return;
  if (this.saving) return;
  if (this.destroyed) return;
  // console.log("cube.save()");
  this.saving = "true";
  var params = {};
  params.cube = {};
  params.cube.position = this.position;
  params.cube.text = this.text;
  params.cube.cube_type = this.cubeType;
  var url = this.url;
  if (this.id != null) {
    url += "/" + this.id;
    params._method = "patch";
  }
  // console.log(params);


  // Fridge.post(url, params, this._saveDone, this._saveFail, event_type);

  var request = Fridge._requestPost(url);

  var that = this;
  request.onreadystatechange = function() {
    if (this.readyState == 4 && this.status >= 200 && this.status < 300) {
      that._saveDone(request, event_type);
    } else if (this.readyState == 4) {
      that._saveFail(request);
    }
  };
  request.send(serializeForXMLHttpRequest(params));
};

Cube.prototype.destroy = function() {
  // console.log("cube.destroy();");
  this.destroyed = "true";
  if (!this.id) return;
  var params = {};
  params._method = "delete";
  var url = this.url + "/" + this.id;

  Fridge.post(url, params);
};


Cube.prototype.saveFacePositions = function() {
  // console.log("cube.saveFacePositions();");
  var url = "";
  var changes = false;
  var params = {};
  params.faces = {};

  url = this.url + "/" + this.id + "/" + "faces/positions";

  this.faces.forEach(function(face, index) {
    if (!face._positionChanged()) return true; // TODO: Change calling of "private" method?
    params.faces[face.id] = { "position": face.position };
    changes = true;
  });

  // console.log(params);
  if (!changes) return;

  Fridge.post(url, params, this._saveFacePositionsDone, this._saveFacePositionsFail);
};

Cube.prototype._saveFacePositionsDone = function(request) {
  var data = JSON.parse(request.responseText);
  if (data != null) {
    data.forEach(function(datum) {
      var element = document.querySelector("[data-object~=\"face-wrapper\"][data-face=\"" + datum.id + "\"]");
      var face = new Face(element, this);
      if (face.wrapper) {
        face.positionOriginal = datum.position;
        face.redrawPosition();
      } else {
        console.error("Face #" + datum.id + " not found.");
      }
    });
  }
};

Cube.prototype._saveFacePositionsFail = function(request) {
  console.error(request);
};
