if(typeof(String.prototype.trim) === "undefined") {
  String.prototype.trim = function(){
    return String(this).replace(/^\s+|\s+$/g, '');
  };
}
