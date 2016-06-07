@clearImperialHeightFields = (element) ->
  target_name = element.data("target-name")
  clearClassStyles(target_name)
  $("##{target_name}_feet").val("")
  $("##{target_name}_inches").val("")
  $("##{target_name}_feet").change()
  $("##{target_name}_feet").blur()

@clearImperialWeightFields = (element) ->
  target_name = element.data("target-name")
  clearClassStyles(target_name)
  $("##{target_name}_pounds").val("")
  $("##{target_name}_ounces").val("")
  $("##{target_name}_pounds").change()
  $("##{target_name}_pounds").blur()

$(document)
  .on('click', '[data-object~="clear-imperial-height-input"]', (event) ->
    clearImperialHeightFields($(this))
    event.preventDefault()
  )
  .on('click', '[data-object~="clear-imperial-weight-input"]', (event) ->
    clearImperialWeightFields($(this))
    event.preventDefault()
  )
