"use strict";

Face.prototype._saveDone = function(request, event_type) {
  var data = JSON.parse(request.responseText);
  if (data != null) {
    this.positionOriginal = data.position;
    this.id = data.id;
    this.textOriginal = data.text;
    this.text = data.text;
    this.saving = "false";
    this.redraw();
    if (event_type == "blur") this.cube.saveFacePositions(); // TODO: Check if saveFacePositions is needed here.
  }
};

Face.prototype._saveFail = function(request) {
  this.saving = "false";
  console.error(request);
};

Face.prototype.save = function(event_type) {
  if (this.unchanged()) return;
  if (this.saving) return;
  if (this.destroyed) return;
  // console.log("face.save()");
  this.saving = "true";
  var params = {};
  params.face = {};
  params.face.position = this.position;
  params.face.text = this.text;

  var url = this.cube.url; // TODO: Refactor how URLs are generated.
  if (this.cube.id != null) {
    url += "/" + this.cube.id + "/faces";
  }
  if (this.id != null) {
    url += "/" + this.id;
    params._method = "patch";
  }

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

Face.prototype.destroy = function() {
  // console.log("face.destroy();");
  this.destroyed = "true";
  if (!this.id) return;
  var params = {};
  params._method = "delete";
  var url = this.url + "/" + this.id;
  Fridge.post(url, params);
};

