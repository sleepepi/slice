$(document)
  .on("DOMNodeInserted", ".turbolinks-progress-bar", ->
    $(".turbolinks-progress-bar").addClass($("body").data("theme"))
  )
