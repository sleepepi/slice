@beep = ->
  return if $("[data-object~=sound-enabled]").length == 0
  snd = new Audio("data:audio/wav;base64,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qJrx4KOQjahZxWbcZgztj2c49nKmkId44S71j0c8eV9yDK6uPRzx5X18eDvjvQ6yKo9ZSS6l//8elePK/Lf//IInrOF/FvDoADYAGBMGb7FtErm5MXMlmPAJQVgWta7Zx2go+8xJ0UiCb8LHHdftWyLJE0QIAIsI+UbXu67dZMjmgDGCGl1H+vpF4NSDckSIkk7Vd+sxEhBQMRU8j/12UIRhzSaUdQ+rQU5kGeFxm+hb1oh6pWWmv3uvmReDl0UnvtapVaIzo1jZbf/pD6ElLqSX+rUmOQNpJFa/r+sa4e/pBlAABoAAAAA3CUgShLdGIxsY7AUABPRrgCABdDuQ5GC7DqPQCgbbJUAoRSUj+NIEig0YfyWUho1VBBBA//uQZB4ABZx5zfMakeAAAAmwAAAAF5F3P0w9GtAAACfAAAAAwLhMDmAYWMgVEG1U0FIGCBgXBXAtfMH10000EEEEEECUBYln03TTTdNBDZopopYvrTTdNa325mImNg3TTPV9q3pmY0xoO6bv3r00y+IDGid/9aaaZTGMuj9mpu9Mpio1dXrr5HERTZSmqU36A3CumzN/9Robv/Xx4v9ijkSRSNLQhAWumap82WRSBUqXStV/YcS+XVLnSS+WLDroqArFkMEsAS+eWmrUzrO0oEmE40RlMZ5+ODIkAyKAGUwZ3mVKmcamcJnMW26MRPgUw6j+LkhyHGVGYjSUUKNpuJUQoOIAyDvEyG8S5yfK6dhZc0Tx1KI/gviKL6qvvFs1+bWtaz58uUNnryq6kt5RzOCkPWlVqVX2a/EEBUdU1KrXLf40GoiiFXK///qpoiDXrOgqDR38JB0bw7SoL+ZB9o1RCkQjQ2CBYZKd/+VJxZRRZlqSkKiws0WFxUyCwsKiMy7hUVFhIaCrNQsKkTIsLivwKKigsj8XYlwt/WKi2N4d//uQRCSAAjURNIHpMZBGYiaQPSYyAAABLAAAAAAAACWAAAAApUF/Mg+0aohSIRobBAsMlO//Kk4soosy1JSFRYWaLC4qZBYWFRGZdwqKiwkNBVmoWFSJkWFxX4FFRQWR+LsS4W/rFRb/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////VEFHAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAU291bmRib3kuZGUAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMjAwNGh0dHA6Ly93d3cuc291bmRib3kuZGUAAAAAAAAAACU=")
  snd.play()

@clearErrorAndWarning = (parent, data) ->
  container = $(parent).closest("[data-object~=design-option-container]")
  container.removeClass("variable-errors") if container.find(".has-error").length == 0
  container.removeClass("variable-warnings") if container.find(".has-warning").length == 0

@setError = (parent, data) ->
  container = $(parent).closest("[data-object~=design-option-container]")
  beep() unless container.hasClass("variable-errors")
  clearErrorAndWarning(parent, data)
  container.addClass("variable-errors")

@setWarning = (parent, data) ->
  clearErrorAndWarning(parent, data)
  container = $(parent).closest("[data-object~=design-option-container]")
  container.addClass("variable-warnings")

@setSuccess = (parent, data) ->
  clearErrorAndWarning(parent, data)

@clearClassStyles = (target_name) ->
  $("##{target_name}_month").parent().removeClass("has-warning has-error")
  $("##{target_name}_day").parent().removeClass("has-warning has-error")
  $("##{target_name}_year").parent().removeClass("has-warning has-error")
  $("##{target_name}_hours").parent().removeClass("has-warning has-error")
  $("##{target_name}_minutes").parent().removeClass("has-warning has-error")
  $("##{target_name}_seconds").parent().removeClass("has-warning has-error")
  $("##{target_name}_period").parent().removeClass("has-warning has-error")
  $("##{target_name}_feet").parent().removeClass("has-warning has-error")
  $("##{target_name}_inches").parent().removeClass("has-warning has-error")
  $("##{target_name}_pounds").parent().removeClass("has-warning has-error")
  $("##{target_name}_ounces").parent().removeClass("has-warning has-error")
  $("##{target_name}").parent().removeClass("has-warning has-error")

@setDefaultClassStyles = (target_name, data) ->
  $("##{target_name}_alert_box").show()
  $("##{target_name}_message").html(data["message"])
  $("##{target_name}_formatted_value").html(data["formatted_value"])
  $("[data-raw-value-for='#{target_name}']").val(data["raw_value"])
  $("[data-raw-value-for='#{target_name}']").change()

@setValidationProperty = (parent, data) ->
  $(parent).data("status", data["status"])
  container = $(parent).closest("[data-object~=design-option-container]")
  if data["status"] in ["invalid", "out_of_range"]
    setError(parent, data)
  else if data["status"] == "blank" and container.data("requirement") == "required"
    setError(parent, data)
  else if (data["status"] == "blank" and container.data("requirement") == "recommended") or (data["status"] == "in_hard_range")
    setWarning(parent, data)
  else
    setSuccess(parent, data)

@setGenericValidityClass = (parent, data) ->
  target_name = parent.data("target-name")
  clearClassStyles(target_name)
  setDefaultClassStyles(target_name, data)

  setValidationProperty(parent, data)

  if data["status"] == "invalid" or data["status"] == "out_of_range"
    $("##{target_name}").parent().addClass("has-error")
  if data["status"] == "in_hard_range"
    $("##{target_name}").parent().addClass("has-warning")
  if data["status"] == "blank" or data["status"] == "in_soft_range"
    $("##{target_name}_alert_box").hide() if data["message"] == ""

@setDateValidityClass = (parent, data) ->
  target_name = parent.data("target-name")
  clearClassStyles(target_name)
  setDefaultClassStyles(target_name, data)

  setValidationProperty(parent, data)

  if data["status"] == "invalid" or data["status"] == "out_of_range"
    $("##{target_name}_year").parent().addClass("has-error")
    $("##{target_name}_month").parent().addClass("has-error")
    $("##{target_name}_day").parent().addClass("has-error")
  if data["status"] == "in_hard_range"
    $("##{target_name}_year").parent().addClass("has-warning")
    $("##{target_name}_month").parent().addClass("has-warning")
    $("##{target_name}_day").parent().addClass("has-warning")
  if data["status"] == "blank" or data["status"] == "in_soft_range"
    $("##{target_name}_alert_box").show()

@setTimeValidityClass = (parent, data) ->
  target_name = parent.data("target-name")
  clearClassStyles(target_name)
  setDefaultClassStyles(target_name, data)

  setValidationProperty(parent, data)

  if data["status"] == "invalid" or data["status"] == "out_of_range"
    $("##{target_name}_hours").parent().addClass("has-error")
    $("##{target_name}_minutes").parent().addClass("has-error")
    $("##{target_name}_seconds").parent().addClass("has-error")
    $("##{target_name}_period").parent().addClass("has-error")
  if data["status"] == "in_hard_range"
    $("##{target_name}_hours").parent().addClass("has-warning")
    $("##{target_name}_minutes").parent().addClass("has-warning")
    $("##{target_name}_seconds").parent().addClass("has-warning")
    $("##{target_name}_period").parent().addClass("has-warning")
  if data["status"] == "blank" or data["status"] == "in_soft_range"
    $("##{target_name}_alert_box").show()

@setImperialHeightValidityClass = (parent, data) ->
  target_name = parent.data("target-name")
  clearClassStyles(target_name)
  setDefaultClassStyles(target_name, data)
  setValidationProperty(parent, data)
  if data["status"] == "invalid" or data["status"] == "out_of_range"
    $("##{target_name}_feet").parent().addClass("has-error")
    $("##{target_name}_inches").parent().addClass("has-error")
  if data["status"] == "in_hard_range"
    $("##{target_name}_feet").parent().addClass("has-warning")
    $("##{target_name}_inches").parent().addClass("has-warning")
  if data["status"] == "blank" or data["status"] == "in_soft_range"
    $("##{target_name}_alert_box").show()

@setImperialWeightValidityClass = (parent, data) ->
  target_name = parent.data("target-name")
  clearClassStyles(target_name)
  setDefaultClassStyles(target_name, data)
  setValidationProperty(parent, data)
  if data["status"] == "invalid" or data["status"] == "out_of_range"
    $("##{target_name}_pounds").parent().addClass("has-error")
    $("##{target_name}_ounces").parent().addClass("has-error")
  if data["status"] == "in_hard_range"
    $("##{target_name}_pounds").parent().addClass("has-warning")
    $("##{target_name}_ounces").parent().addClass("has-warning")
  if data["status"] == "blank" or data["status"] == "in_soft_range"
    $("##{target_name}_alert_box").show()

@setVariableValidityClass = (parent, data) ->
  if $(parent).data("components") == "date"
    setDateValidityClass(parent, data)
  else if $(parent).data("components") == "time_of_day"
    setTimeValidityClass(parent, data)
  else if $(parent).data("components") == "time_duration"
    setTimeValidityClass(parent, data)
  else if $(parent).data("components") == "imperial_height"
    setImperialHeightValidityClass(parent, data)
  else if $(parent).data("components") == "imperial_weight"
    setImperialWeightValidityClass(parent, data)
  else
    setGenericValidityClass(parent, data)
  checkRequiredAndInvalidFormat()

@valueToJSON = (parent) ->
  switch $(parent).data("components")
    when "date"
      value = {}
      value["month"]  = $("##{$(parent).data("target-name")}_month").val()
      value["day"]    = $("##{$(parent).data("target-name")}_day").val()
      value["year"]   = $("##{$(parent).data("target-name")}_year").val()
    when "time_of_day"
      value = {}
      value["hours"]    = $("##{$(parent).data("target-name")}_hours").val()
      value["minutes"] = $("##{$(parent).data("target-name")}_minutes").val()
      value["seconds"] = $("##{$(parent).data("target-name")}_seconds").val()
      value["period"]  = $("##{$(parent).data("target-name")}_period").val()
    when "time_duration"
      value = {}
      value["hours"]    = $("##{$(parent).data("target-name")}_hours").val()
      value["minutes"] = $("##{$(parent).data("target-name")}_minutes").val()
      value["seconds"] = $("##{$(parent).data("target-name")}_seconds").val()
    when "imperial_height"
      value = {}
      value["feet"]    = $("##{$(parent).data("target-name")}_feet").val()
      value["inches"] = $("##{$(parent).data("target-name")}_inches").val()
    when "imperial_weight"
      value = {}
      value["pounds"]    = $("##{$(parent).data("target-name")}_pounds").val()
      value["ounces"] = $("##{$(parent).data("target-name")}_ounces").val()
    when "checkbox"
      value = []
      children = $(parent).find("input:checked")
      $.each(children, (index, child) ->
        value.push($(child).val())
      )
    when "radio"
      value = ""
      children = $(parent).find("input:checked")
      $.each(children, (index, child) ->
        value = $(child).val()
      )
    else
      value = $("##{$(parent).data("target-name")}").val()
  value

@stayActiveDuringSheetEntry = ->
  $.post("#{root_url}keep-me-active", null, null, "script") if $("[data-object~=current-user]").length > 0

@validateElement = (element, relatedTarget = null) ->
  stayActiveDuringSheetEntry()
  return if relatedTarget? and $(relatedTarget).data("target-name")? and $(element).data("target-name")? and $(element).data("target-name") == $(relatedTarget).data("target-name")

  parent = $(element).closest("[data-object~=validate]")
  params = {}
  params.value = valueToJSON(parent)
  params.language = $("[name=language]").val()

  $.ajax(
    url: $(parent).data("validate-url")
    type: "POST"
    dataType: "json"
    data: params
  ).done( (data) ->
    setVariableValidityClass(parent, data)
  ).fail( (jqXHR, textStatus, errorThrown) ->
    console.log("FAIL: #{textStatus} #{errorThrown}")
  )

@checkRequiredAndInvalidFormat = ->
  fields = $("[data-requirement~=required]:visible").find("[data-status]:visible").filter( ->
    $(this).data("status") == "blank" || $(this).data("status") == "invalid"
  )

  out_of_range_fields = $("[data-status]:visible").filter( ->
    $(this).data("status") == "out_of_range"
  )

  field_count = fields.length + out_of_range_fields.length

  if field_count > 0
    $("#validation-messages").html("#{field_count} error#{if field_count == 1 then "" else "s"} found. Scroll to error.")
  else
    $("#validation-messages").html("")

$(document)
  .on("blur", "[data-object~=validate] input, [data-object~=validate] textarea, [data-object~=validate] select", (e) ->
    relatedTarget = e.relatedTarget || e.toElement;
    validateElement($(this), $(relatedTarget))
  )
  .on("change", "[data-object~=validate] input:checkbox, [data-object~=validate] input:radio, [data-object~=validate] select", ->
    validateElement($(this))
  )
  .on("click", "[data-object~=scroll-to-first-error]", ->
    fields = $("[data-requirement~=required]:visible").find("[data-status]:visible").filter( ->
      $(this).data("status") == "blank" || $(this).data("status") == "invalid"
    )
    out_of_range_fields = $("[data-status]:visible").filter( ->
      $(this).data("status") == "out_of_range"
    )
    if fields.length > 0
      field = fields[0]
    else if out_of_range_fields.length > 0
      field = out_of_range_fields[0]

    if field
      validateElement(field)
      $("html, body").animate { scrollTop: $(field).offset().top - 100 }, 400
  )
