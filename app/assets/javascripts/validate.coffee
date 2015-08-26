# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@clearClassStyles = (target_name) ->
  $("##{target_name}_month").parent().removeClass('has-warning')
  $("##{target_name}_day").parent().removeClass('has-warning')
  $("##{target_name}_year").parent().removeClass('has-warning')
  $("##{target_name}_month").parent().removeClass('has-error')
  $("##{target_name}_day").parent().removeClass('has-error')
  $("##{target_name}_year").parent().removeClass('has-error')
  $("##{target_name}_error").hide()
  $("##{target_name}_warning").hide()
  $("##{target_name}_success").hide()
  $("##{target_name}_alert_box").removeClass('bs-callout-success')
  $("##{target_name}_alert_box").removeClass('bs-callout-warning')
  $("##{target_name}_alert_box").removeClass('bs-callout-danger')

@setDefaultClassStyles = (target_name, data) ->
  $("##{target_name}_alert_box").show()
  $("##{target_name}_alert_box").addClass('bs-callout-success')
  $("##{target_name}_message").html(data['message'])

@setGenericValidityClass = (parent, data) ->
  target_name = parent.data("target-name")
  clearClassStyles(target_name)
  setDefaultClassStyles(target_name, data)

  if data['status'] == 'invalid' or data['status'] == 'out_of_range'
    $("##{target_name}_error").show()
    $("##{target_name}_alert_box").addClass('bs-callout-danger')
  if data['status'] == 'in_hard_range'
    $("##{target_name}_warning").show()
    $("##{target_name}_alert_box").addClass('bs-callout-warning')
  if data['status'] == 'blank' or data['status'] == 'in_soft_range'
    $("##{target_name}_success").show()
    $("##{target_name}_alert_box").show()

@setDateValidityClass = (parent, data) ->
  target_name = parent.data("target-name")
  clearClassStyles(target_name)
  setDefaultClassStyles(target_name, data)

  $("##{target_name}_date_string").html(data['date_string'])

  if data['status'] == 'invalid' or data['status'] == 'out_of_range'
    $("##{target_name}_error").show()
    $("##{target_name}_alert_box").addClass('bs-callout-danger')
    $("##{target_name}_year").parent().addClass('has-error')
    $("##{target_name}_month").parent().addClass('has-error')
    $("##{target_name}_day").parent().addClass('has-error')
  if data['status'] == 'in_hard_range'
    $("##{target_name}_warning").show()
    $("##{target_name}_year").parent().addClass('has-warning')
    $("##{target_name}_month").parent().addClass('has-warning')
    $("##{target_name}_day").parent().addClass('has-warning')
    $("##{target_name}_alert_box").addClass('bs-callout-warning')
  if data['status'] == 'blank' or data['status'] == 'in_soft_range'
    $("##{target_name}_success").show()
    $("##{target_name}_alert_box").show()



@setVariableValidityClass = (parent, data) ->
  if $(parent).data('components') == 'date'
    setDateValidityClass(parent, data)
  else
    setGenericValidityClass(parent, data)

@valueToJSON = (parent) ->
  switch $(parent).data('components')
    when 'date'
      value = {}
      value["month"]  = $("##{$(parent).data('target-name')}_month").val()
      value["day"]    = $("##{$(parent).data('target-name')}_day").val()
      value["year"]   = $("##{$(parent).data('target-name')}_year").val()
    when 'checkbox'
      value = []
      children = $(parent).find('input')
      $.each(children, (index, child) ->
        value.push(child.val()) if child.prop('checked', true)
      )
    else
      value = $("##{$(parent).data('target-name')}").val()
  value

@validateElement = (element) ->
  parent = $(element).closest('[data-object~="validate"]')

  changes = {}
  changes["project_id"] = $(parent).data('project-id')
  changes["design_id"] = $(parent).data('design-id')
  changes["variable_id"] = $(parent).data('variable-id')
  changes["value"] = valueToJSON(parent)

  url = root_url + 'validate/variable'

  $.ajax(
    url: url
    type: 'POST'
    dataType: 'json'
    data: changes
  ).done( (data) ->
    setVariableValidityClass(parent, data)
  ).fail( (jqXHR, textStatus, errorThrown) ->
    console.log("FAIL: #{textStatus} #{errorThrown}")
  )

$(document)
  # .on('change', '[data-object~="validate"] input', () ->
  #   validateElement($(this))
  # )
  .on('blur', '[data-object~="validate"] input', () ->
    validateElement($(this))
  )
