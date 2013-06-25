clearSelections = (member) ->
  $(member).closest(".control-group").find("input:radio, input:checkbox")
    .prop('checked', false)
    .data('previous', 'unchecked')
    .parent().removeClass("selected")
  updateAllVariables()
  updateCalculatedVariables()

selectWithKeystroke = (event) ->
  # input field has to be radio button or checkbox
  if event.which == 192
    clearSelections(event.target)
  else
    selected_value = String.fromCharCode(event.which)
    selected_input = $(event.target).closest(".control-group").find("*[value='" + selected_value + "']").first()
    selected_input.prop("checked", true) if selected_input
    selected_input.change()

jQuery ->
  $(document).on("keydown", ".radio input:radio", selectWithKeystroke)
  $(document).on("keydown", ".checkbox input:checkbox", selectWithKeystroke)



