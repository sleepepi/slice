"use strict";

function Fridge() {}

Fridge._requestPost = function(url) {
  var request = new XMLHttpRequest();
  request.open("POST", url, true);
  request.setRequestHeader("Accept", "application/json");
  request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded; charset=UTF-8");
  request.setRequestHeader("X-CSRF-Token", csrfToken());
  // request.setRequestHeader("X-Requested-With", "XMLHttpRequest");
  return request;
};

Fridge.post = function(url, params, success, fail, successparam) {
  var request = Fridge._requestPost(url);
  request.onreadystatechange = function() {
    if (success && this.readyState == 4 && this.status >= 200 && this.status < 300) {
      if (successparam) {
        success(request, successparam);
      } else {
        success(request);
      }
    } else if (fail && this.readyState == 4) {
      fail(request);
    }
  };
  request.send(serializeForXMLHttpRequest(params));
};
