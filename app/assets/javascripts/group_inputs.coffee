@clearSelections = (member) ->
  $("input[name='" + $(member).attr("name") + "']")
    .prop('checked', false)
    .parent().removeClass("selected")
  $("input[name='" + $(member).attr("name") + "']").data('previous', 'unchecked')
  updateAllVariables()
  updateCalculatedVariables()


@toggleGroupInput = (input, group_name, event) ->
  if input.parent("label").hasClass("selected") and (input.attr('type') == "checkbox" or event.type == "click")
    input.prop("checked", false)
    input.parent("label").removeClass("selected")
  else
    input.prop("checked", true)
    $("input[name='" + group_name + "']").parent("label").removeClass("selected") unless input.attr('type') == "checkbox"
    input.parent("label").addClass("selected")
  input.focus()
  input.change()

# input field has to be radio button or checkbox
#  96 = backtick (`)
# 126 = tilda    (~)
@selectWithKeystroke = (event) ->
  if event.which == 96 or event.which == 126
    clearSelections(event.target)
  else
    selected_value = String.fromCharCode(event.which)
    group_name = $(event.target).attr("name")
    input = $("*[name='"+ group_name + "'][value='" + selected_value + "']")
    toggleGroupInput(input, group_name, event) if input.length > 0
  $(event.target).change()


$(document)
  .on("keypress", ".radio input:radio", selectWithKeystroke)
  .on("keypress", ".checkbox input:checkbox", selectWithKeystroke)
  .on("click", ".radio input:radio", (event) ->
    radio = $(this)
    group_name = radio.attr("name")
    toggleGroupInput(radio, group_name, event)
  )
  .on("click", ".checkbox input:checkbox", () ->
    $(this).focus()
  )
  .on("focus", ".radio input:radio, .checkbox input:checkbox", () ->
    $(this).parent().addClass("focus")
  )
  .on("focusout", ".radio input:radio, .checkbox input:checkbox", () ->
    $(this).parent().removeClass("focus")
  )
