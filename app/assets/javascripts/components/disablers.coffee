@disablerWithSpinner = (element) ->
  $element = $(element)
  $element.css("width", $element.css("width"))
  $element.prop("disabled", true)
  $element.addClass("disabled")
  $element.html("<i class=\"fa fa-spin fa-spinner\"></i>")

$(document)
  .on("click", "[data-object~=disable-spinner]", ->
    disablerWithSpinner($(this))
  )
