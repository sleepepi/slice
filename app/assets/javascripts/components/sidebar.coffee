$(document)
  .on("click", "[data-object~=sidebar-show]", ->
    $("#sidebar-mini").hide()
    $("#sidebarbubble-nav-wrapper").addClass("show")
    false
  )
  .on("click", "[data-object~=sidebar-hide]", ->
    $("#sidebarbubble-nav-wrapper").removeClass("show")
    $("#sidebar-mini").show()
    false
  )
