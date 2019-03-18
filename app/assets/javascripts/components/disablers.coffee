@renableSpinnerButton = (element) ->
  $element = $(element)
  $element.css("width", null)
  $element.prop("disabled", false)
  $element.removeClass("disabled")
  $element.html($element.data("spinner-button-html"))

@disableWithSpinner = (element, text=null) ->
  $element = $(element)
  $element.css("width", $element.css("width"))
  $element.prop("disabled", true)
  $element.addClass("disabled")
  $element.data("spinner-button-html", $element.html())
  spinnerHtml = "<i class=\"fas fa-spinner fa-spin\"></i>"
  spinnerHtml += " #{text}" if !!text
  $element.html(spinnerHtml)

$(document)
  .on("click", "[data-object~=disable-spinner]", ->
    disableWithSpinner($(this))
  )
