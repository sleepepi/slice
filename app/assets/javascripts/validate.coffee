@clearErrorAndWarning = (parent, data) ->
  container = $(parent).closest('[data-object~="design-option-container"]')
  container.removeClass('variable-errors') if container.find('.has-error').length == 0
  container.removeClass('variable-warnings') if container.find('.has-warning').length == 0

@setError = (parent, data) ->
  clearErrorAndWarning(parent, data)
  container = $(parent).closest('[data-object~="design-option-container"]')
  container.addClass('variable-errors')

@setWarning = (parent, data) ->
  clearErrorAndWarning(parent, data)
  container = $(parent).closest('[data-object~="design-option-container"]')
  container.addClass('variable-warnings')

@setSuccess = (parent, data) ->
  clearErrorAndWarning(parent, data)

@clearClassStyles = (target_name) ->
  $("##{target_name}_month").parent().removeClass('has-warning has-error')
  $("##{target_name}_day").parent().removeClass('has-warning has-error')
  $("##{target_name}_year").parent().removeClass('has-warning has-error')
  $("##{target_name}_hours").parent().removeClass('has-warning has-error')
  $("##{target_name}_minutes").parent().removeClass('has-warning has-error')
  $("##{target_name}_seconds").parent().removeClass('has-warning has-error')
  $("##{target_name}_period").parent().removeClass('has-warning has-error')
  $("##{target_name}_feet").parent().removeClass('has-warning has-error')
  $("##{target_name}_inches").parent().removeClass('has-warning has-error')
  $("##{target_name}_pounds").parent().removeClass('has-warning has-error')
  $("##{target_name}_ounces").parent().removeClass('has-warning has-error')
  $("##{target_name}").parent().removeClass('has-warning has-error')
  $("##{target_name}_alert_box")
    .removeClass('callout-warning callout-danger')

@setDefaultClassStyles = (target_name, data) ->
  $("##{target_name}_alert_box").show()
  $("##{target_name}_message").html(data['message'])
  $("##{target_name}_formatted_value").html(data['formatted_value'])
  $("[data-raw-value-for='#{target_name}']").val(data['raw_value'])
  $("[data-raw-value-for='#{target_name}']").change()

@setValidationProperty = (parent, data) ->
  $(parent).data('status', data['status'])
  container = $(parent).closest('[data-object~="design-option-container"]')
  if data['status'] in ['invalid', 'out_of_range']
    setError(parent, data)
  else if data['status'] == 'blank' and container.data('required') == 'required'
    setError(parent, data)
  else if (data['status'] == 'blank' and container.data('required') == 'recommended') or (data['status'] == 'in_hard_range')
    setWarning(parent, data)
  else
    setSuccess(parent, data)

@setGenericValidityClass = (parent, data) ->
  target_name = parent.data("target-name")
  clearClassStyles(target_name)
  setDefaultClassStyles(target_name, data)

  setValidationProperty(parent, data)

  if data['status'] == 'invalid' or data['status'] == 'out_of_range'
    $("##{target_name}").parent().addClass('has-error')
    $("##{target_name}_alert_box").addClass('callout-danger')
  if data['status'] == 'in_hard_range'
    $("##{target_name}").parent().addClass('has-warning')
    $("##{target_name}_alert_box").addClass('callout-warning')
  if data['status'] == 'blank' or data['status'] == 'in_soft_range'
    $("##{target_name}_alert_box").hide() if data['message'] == ''

@setDateValidityClass = (parent, data) ->
  target_name = parent.data("target-name")
  clearClassStyles(target_name)
  setDefaultClassStyles(target_name, data)

  setValidationProperty(parent, data)

  if data['status'] == 'invalid' or data['status'] == 'out_of_range'
    $("##{target_name}_alert_box").addClass('callout-danger')
    $("##{target_name}_year").parent().addClass('has-error')
    $("##{target_name}_month").parent().addClass('has-error')
    $("##{target_name}_day").parent().addClass('has-error')
  if data['status'] == 'in_hard_range'
    $("##{target_name}_year").parent().addClass('has-warning')
    $("##{target_name}_month").parent().addClass('has-warning')
    $("##{target_name}_day").parent().addClass('has-warning')
    $("##{target_name}_alert_box").addClass('callout-warning')
  if data['status'] == 'blank' or data['status'] == 'in_soft_range'
    $("##{target_name}_alert_box").show()

@setTimeValidityClass = (parent, data) ->
  target_name = parent.data("target-name")
  clearClassStyles(target_name)
  setDefaultClassStyles(target_name, data)

  setValidationProperty(parent, data)

  if data['status'] == 'invalid' or data['status'] == 'out_of_range'
    $("##{target_name}_alert_box").addClass('callout-danger')
    $("##{target_name}_hours").parent().addClass('has-error')
    $("##{target_name}_minutes").parent().addClass('has-error')
    $("##{target_name}_seconds").parent().addClass('has-error')
    $("##{target_name}_period").parent().addClass('has-error')
  if data['status'] == 'in_hard_range'
    $("##{target_name}_hours").parent().addClass('has-warning')
    $("##{target_name}_minutes").parent().addClass('has-warning')
    $("##{target_name}_seconds").parent().addClass('has-warning')
    $("##{target_name}_period").parent().addClass('has-warning')
    $("##{target_name}_alert_box").addClass('callout-warning')
  if data['status'] == 'blank' or data['status'] == 'in_soft_range'
    $("##{target_name}_alert_box").show()

@setImperialHeightValidityClass = (parent, data) ->
  target_name = parent.data("target-name")
  clearClassStyles(target_name)
  setDefaultClassStyles(target_name, data)
  setValidationProperty(parent, data)
  if data['status'] == 'invalid' or data['status'] == 'out_of_range'
    $("##{target_name}_alert_box").addClass('callout-danger')
    $("##{target_name}_feet").parent().addClass('has-error')
    $("##{target_name}_inches").parent().addClass('has-error')
  if data['status'] == 'in_hard_range'
    $("##{target_name}_feet").parent().addClass('has-warning')
    $("##{target_name}_inches").parent().addClass('has-warning')
    $("##{target_name}_alert_box").addClass('callout-warning')
  if data['status'] == 'blank' or data['status'] == 'in_soft_range'
    $("##{target_name}_alert_box").show()

@setImperialWeightValidityClass = (parent, data) ->
  target_name = parent.data("target-name")
  clearClassStyles(target_name)
  setDefaultClassStyles(target_name, data)
  setValidationProperty(parent, data)
  if data['status'] == 'invalid' or data['status'] == 'out_of_range'
    $("##{target_name}_alert_box").addClass('callout-danger')
    $("##{target_name}_pounds").parent().addClass('has-error')
    $("##{target_name}_ounces").parent().addClass('has-error')
  if data['status'] == 'in_hard_range'
    $("##{target_name}_pounds").parent().addClass('has-warning')
    $("##{target_name}_ounces").parent().addClass('has-warning')
    $("##{target_name}_alert_box").addClass('callout-warning')
  if data['status'] == 'blank' or data['status'] == 'in_soft_range'
    $("##{target_name}_alert_box").show()

@setVariableValidityClass = (parent, data) ->
  if $(parent).data('components') == 'date'
    setDateValidityClass(parent, data)
  else if $(parent).data('components') == 'time'
    setTimeValidityClass(parent, data)
  else if $(parent).data('components') == 'time_duration'
    setTimeValidityClass(parent, data)
  else if $(parent).data('components') == 'imperial_height'
    setImperialHeightValidityClass(parent, data)
  else if $(parent).data('components') == 'imperial_weight'
    setImperialWeightValidityClass(parent, data)
  else
    setGenericValidityClass(parent, data)
  checkRequiredAndInvalidFormat()

@valueToJSON = (parent) ->
  switch $(parent).data('components')
    when 'date'
      value = {}
      value["month"]  = $("##{$(parent).data('target-name')}_month").val()
      value["day"]    = $("##{$(parent).data('target-name')}_day").val()
      value["year"]   = $("##{$(parent).data('target-name')}_year").val()
    when 'time'
      value = {}
      value["hours"]    = $("##{$(parent).data('target-name')}_hours").val()
      value["minutes"] = $("##{$(parent).data('target-name')}_minutes").val()
      value["seconds"] = $("##{$(parent).data('target-name')}_seconds").val()
      value["period"]  = $("##{$(parent).data('target-name')}_period").val()
    when 'time_duration'
      value = {}
      value["hours"]    = $("##{$(parent).data('target-name')}_hours").val()
      value["minutes"] = $("##{$(parent).data('target-name')}_minutes").val()
      value["seconds"] = $("##{$(parent).data('target-name')}_seconds").val()
    when 'imperial_height'
      value = {}
      value["feet"]    = $("##{$(parent).data('target-name')}_feet").val()
      value["inches"] = $("##{$(parent).data('target-name')}_inches").val()
    when 'imperial_weight'
      value = {}
      value["pounds"]    = $("##{$(parent).data('target-name')}_pounds").val()
      value["ounces"] = $("##{$(parent).data('target-name')}_ounces").val()
    when 'checkbox'
      value = []
      children = $(parent).find('input:checked')
      $.each(children, (index, child) ->
        value.push($(child).val())
      )
    when 'radio'
      value = ''
      children = $(parent).find('input:checked')
      $.each(children, (index, child) ->
        value = $(child).val()
      )
    else
      value = $("##{$(parent).data('target-name')}").val()
  value

@validateElement = (element, relatedTarget = null) ->
  return if relatedTarget? and $(relatedTarget).data('target-name')? and $(element).data('target-name')? and $(element).data('target-name') == $(relatedTarget).data('target-name')

  parent = $(element).closest('[data-object~="validate"]')
  params = {}
  params.project_id = $(parent).data('project-id')
  params.variable_id = $(parent).data('variable-id')
  params.value = valueToJSON(parent)

  $.ajax(
    url: "#{root_url}validate/variable"
    type: 'POST'
    dataType: 'json'
    data: params
  ).done( (data) ->
    setVariableValidityClass(parent, data)
  ).fail( (jqXHR, textStatus, errorThrown) ->
    console.log("FAIL: #{textStatus} #{errorThrown}")
  )

@checkRequiredAndInvalidFormat = ->
  fields = $('[data-required~="required"]:visible').find('[data-status]:visible').filter( ->
    $(this).data('status') == "blank" || $(this).data('status') == "invalid"
  )

  out_of_range_fields = $('[data-status]:visible').filter( ->
    $(this).data('status') == "out_of_range"
  )

  field_count = fields.length + out_of_range_fields.length

  if field_count > 0
    $("#validation-messages").html("#{field_count} error#{if field_count == 1 then '' else 's'} found. Scroll to error.")
  else
    $("#validation-messages").html("")

$(document)
  .on('blur', '[data-object~="validate"] input, [data-object~="validate"] textarea', (e) ->
    relatedTarget = e.relatedTarget || e.toElement;
    validateElement($(this), $(relatedTarget))
  )
  .on('change', '[data-object~="validate"] input:checkbox, [data-object~="validate"] input:radio, [data-object~="validate"] select', ->
    validateElement($(this))
  )
  .on('click', '[data-object~="scroll-to-first-error"]', ->
    fields = $('[data-required~="required"]:visible').find('[data-status]:visible').filter( ->
      $(this).data('status') == "blank" || $(this).data('status') == "invalid"
    )
    out_of_range_fields = $('[data-status]:visible').filter( ->
      $(this).data('status') == "out_of_range"
    )
    if fields.length > 0
      field = fields[0]
    else if out_of_range_fields.length > 0
      field = out_of_range_fields[0]

    if field
      validateElement(field)
      $('html, body').animate { scrollTop: $(field).offset().top - 100 }, 400
  )
