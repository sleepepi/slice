clearSelections = (member) ->
  $("input[name='" + $(member).attr("name") + "']")
    .prop('checked', false)
    .parent().removeClass("selected")
  $("input[name='" + $(member).attr("name") + "']").data('previous', 'unchecked')
  updateAllVariables()
  updateCalculatedVariables()

selectWithKeystroke = (event) ->
  # input field has to be radio button or checkbox
  if event.which == 192
    clearSelections(event.target)
  else
    selected_value = String.fromCharCode(event.which)
    group_name = $(event.target).attr("name")
    $("*[name='"+ group_name + "'][value='" + selected_value + "']")
      .prop("checked", true)
      .data('previous', 'checked')
      .change()

jQuery ->
  $(document).on("keydown", ".radio input:radio", selectWithKeystroke)
  $(document).on("keydown", ".checkbox input:checkbox", selectWithKeystroke)
  $(document).on("click", ".radio input:radio", () ->
    radio = $(this)
    if radio.data("previous") == "checked"
      radio.prop("checked", false)
      radio.data("previous", "unchecked")
    else if radio.data("previous") == "unchecked"
      radio.data("previous", "checked")

    radio.change()
    radio.focus()
  )
  $(document).on("click", ".checkbox input:checkbox", () ->
    $(this).focus()
  )





