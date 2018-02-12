@toggleMutuallyExclusive = (element) ->
  group_name = $(element).attr("name")
  if $("input[name=\"#{group_name}\"][data-mutually-exclusive=true]").length > 0
    if $(element).data("mutually-exclusive") && $(element).prop("checked") == true
      $("input[name=\"#{group_name}\"]").prop("checked", false)
      $(element).prop("checked", true)
    else
      $("input[name=\"#{group_name}\"][data-mutually-exclusive=true]").prop("checked", false)
  $("input[name=\"#{$(element).attr("name")}\"]:not(:checked)")
    .closest(".custom-control").removeClass("selected")
  $("input[name=\"#{$(element).attr("name")}\"]:checked")
    .closest(".custom-control").addClass("selected")

@clearSelections = (element) ->
  group_name = $(element).attr("name")
  $("input[name=\"#{group_name}\"]").prop("checked", false)
  $(element).change()
  toggleMutuallyExclusive(element)
  updateAllDesignOptionsVisibility()
  updateCalculatedVariables()

@toggleGroupInput = (element, group_name, event) ->
  console.log "toggleGroupInput"
  if element.closest(".custom-control").hasClass("selected") and (element.attr("type") == "checkbox" or event.type == "click")
    element.prop("checked", false)
  else
    element.prop("checked", true)
  toggleMutuallyExclusive(element)
  element.focus()
  element.change()

# input field has to be radio button or checkbox
#  96 = backtick (`)
# 126 = tilda    (~)
@selectWithKeystroke = (event) ->
  if event.which == 96 or event.which == 126
    clearSelections(event.target)
  else
    selected_value = String.fromCharCode(event.which)
    group_name = $(event.target).attr("name")
    element = $("*[name=\"#{group_name}\"][value=\"#{selected_value}\"]")
    toggleGroupInput(element, group_name, event) if element.length > 0

$(document)
  .on("keypress", ".custom-control.custom-checkbox input, .custom-control.custom-radio input", selectWithKeystroke)
  .on("click", ".custom-control.custom-radio input:radio", (event) ->
    toggleGroupInput($(this), $(this).attr("name"), event)
  )
  .on("click", ".custom-control.custom-checkbox input:checkbox", ->
    $(this).focus()
  )
  .on("change", ".custom-control.custom-checkbox input:checkbox", ->
    toggleMutuallyExclusive($(this))
  )
