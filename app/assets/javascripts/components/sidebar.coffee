$(document)
  .on("click", "[data-object~=sidebar-show]", ->
    $("#sidebar-mini").hide()
    $("#sidebar-nav-wrapper").addClass("show")
    false
  )
  .on("click", "[data-object~=sidebar-hide]", ->
    $("#sidebar-nav-wrapper").removeClass("show")
    $("#sidebar-mini").show()
    false
  )
