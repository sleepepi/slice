@refreshPreview = (project, sform) ->
  $.get("#{root_url}editor/projects/#{project}/forms/#{sform}/builder", null, null, "script")
  console.log "refreshPreview"


@sformElement = (project, sform, value) ->
  $("<input>"
    class: "sform-input"
    "data-object": "sform-core-input"
    "data-changed": false
    "data-project": project
    "data-sform": sform
    "data-value": ""
    placeholder: "Enter question."
    type: "text"
    value: value
  )

@saveSformObject = (element, refresh = true) ->
  return if $(element).data("value") == $(element).val()
  project = $(element).data("project")
  sform = $(element).data("sform")
  params = {}
  params.display_name = $(element).val()
  params.design_option_id = $(element).data("design-option")
  console.log params
  $.post(
    "#{root_url}editor/projects/#{project}/forms/#{sform}/builder/save-object"
    params
    null
    "json"
  ).done((data) ->
    console.log "done: #{data}"
    console.log "done: #{data.design_option_id}"
    $(element).data("design-option", data.design_option_id) if data?
  ).fail((data) ->
    console.log "fail: #{data}"
  )
  $(element).data("value", $(element).val())
  refreshPreview(project, sform) if refresh

@removeSformObject = (element, refresh = true) ->
  return unless $(element).data("design-option")?
  return if $(element).data("design-option")? && $(element).data("design-option") == ""
  project = $(element).data("project")
  sform = $(element).data("sform")
  params = {}
  params.design_option_id = $(element).data("design-option")
  $.post(
    "#{root_url}editor/projects/#{project}/forms/#{sform}/builder/remove-object"
    params
    null
    "json"
  )
  refreshPreview(project, sform) if refresh

@setCursorAtStart = (element) ->
  $(element)[0].setSelectionRange(0, 0)

@insertTextAtCursor = (element, text) ->
  return if document.execCommand("insertText", false, text)
  # Fallback
  selection = $(element).getSelection()
  if selection?
    console.log "FF fallback"
    original_text = $(element).val()
    new_text = original_text.substring(0, selection.start) + text + original_text.substring(selection.end)
    $(element).val(new_text)
  else
    console.log "generic fallback"
    $(element).val(text)

@createNewInputField = (element, value = "") ->
  newElement = sformElement($(element).data("project"), $(element).data("sform"), value)
  $(element).after(newElement)
  saveSformObject(newElement, false)
  $(element).next("[data-object=sform-core-input]")

@sformNextQuestion = (element) ->
  if $(element).next("[data-object=sform-core-input]").length > 0
    setFocusToField($(element).next("[data-object=sform-core-input]"))
  else
    createNewInputField(element)
    setFocusToField($(element).next("[data-object=sform-core-input]"))

@removeObject = (element) ->
  return unless $(element).val() == ""
  $(element).remove()

  removeSformObject($(element))

@sformPrevAndDelete = (element) ->
  setFocusToField($(element).prev())
  removeObject($(element)) if $(element).val() == ""

@sformNextAndDelete = (element) ->
  setFocusToField($(element).next())
  setCursorAtStart($(element).next())
  removeObject($(element)) if $(element).val() == ""

@sformPrev = (element) ->
  setFocusToField($(element).prev())

@sformNext = (element) ->
  setFocusToField($(element).next())

@nothingSelected = (element) ->
  selection = $(element).getSelection()
  return true if selection == null
  selection.length == 0

$(document)
  .on("keydown", "[data-object=sform-core-input]", (e) ->
    $("#output").text e.which
    if e.which == 13
      saveSformObject($(this))
      createNewInputField($(this))
      sformNextQuestion($(this))
      e.preventDefault()
    else if e.which == 8 && $(this).prev("[data-object=sform-core-input]").length > 0 && $(this).getCursorPosition() == 0 && nothingSelected($(this))
      sformPrevAndDelete($(this))
      e.preventDefault()
    else if e.which == 46 && $(this).next("[data-object=sform-core-input]").length > 0 && $(this).getCursorPosition() == 0 && nothingSelected($(this)) && $(this).val() == ""
      sformNextAndDelete($(this))
      e.preventDefault()
    else if e.which == 38 && $(this).prev("[data-object=sform-core-input]").length > 0
      saveSformObject($(this))
      sformPrev($(this))
      e.preventDefault()
    else if e.which == 40 && $(this).next("[data-object=sform-core-input]").length > 0
      saveSformObject($(this))
      sformNext($(this))
      e.preventDefault()
    else if e.which == 66 && e.metaKey
      selection = $(this).getSelection()
      if selection
        padding_start = (selection.text[0] == " ")
        padding_end = (selection.text[selection.text.length - 1] == " ")
        substitute = "#{if padding_start then " " else ""}**#{$.trim(selection.text)}**#{if padding_end then " " else ""}"
        insertTextAtCursor(this, substitute)
      e.preventDefault()
  )
  .on("paste", "[data-object=sform-core-input]", (e) ->
    pastedText = undefined
    $element = $(e.target);

    if (window.clipboardData && window.clipboardData.getData) # IE
      pastedText = window.clipboardData.getData("Text")
    else
      clipboardData = (e.originalEvent || e).clipboardData
      pastedText = clipboardData.getData("text/plain") if (clipboardData && clipboardData.getData)

    selection = $element.getSelection()
    if selection
      pos_start = selection.start
      pos_end = selection.end
    else
      pos_start = pos_end = $element.getCursorPosition()

    original_text = $element.val()
    array = pastedText.split("\n").map((x) -> $.trim(x)).filter((x) -> x.length > 0)


    if array.length > 1 && $element.val() != ""
      # Create a new block and continue
      createNewInputField($element)
    else
      insertTextAtCursor($element, array.shift())

    $nextElement = $element
    multiline = false
    $.each(array, (index, text) ->
      $nextElement = createNewInputField($nextElement, text)
      multiline = true
    )
    setFocusToField($nextElement) if multiline
    e.preventDefault()
    refreshPreview()
    false
  )
