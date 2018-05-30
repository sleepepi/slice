if (!Element.prototype.insertAfter)
  Element.prototype.insertAfter = function(newNode) {
    this.parentNode.insertBefore(newNode, this.nextSibling);
  }
