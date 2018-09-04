@disablerWithSpinner = (element) ->
  $element = $(element)
  $element.css("width", $element.css("width"))
  $element.prop("disabled", true)
  $element.addClass("disabled")
  $element.html("<i class=\"fas fa-spinner fa-spin\"></i>")

$(document)
  .on("click", "[data-object~=disable-spinner]", ->
    disablerWithSpinner($(this))
  )
