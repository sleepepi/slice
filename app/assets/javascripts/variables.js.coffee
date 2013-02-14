# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

@toggleOptions = (element) ->
  if $(element).val() in ['dropdown', 'checkbox', 'radio', 'integer', 'numeric', 'scale']
    $('[data-object~="options"]').show()
  else
    $('[data-object~="options"]').hide()
  if $(element).val() in ['integer', 'numeric']
    $('[data-object~="number"]').show()
  else
    $('[data-object~="number"]').hide()
  if $(element).val() in ['date']
    $('[data-object~="date"]').show()
  else
    $('[data-object~="date"]').hide()
  if $(element).val() in ['calculated']
    $('[data-object~="calculated"]').show()
  else
    $('[data-object~="calculated"]').hide()
  if $(element).val() in ['grid']
    $('[data-object~="grid"]').show()
  else
    $('[data-object~="grid"]').hide()
  if $(element).val() in ['calculated', 'integer', 'numeric']
    $('[data-object~="calculated-or-number"]').show()
  else
    $('[data-object~="calculated-or-number"]').hide()
  if $(element).val() in ['string']
    $('[data-object~="autocomplete"]').show()
  else
    $('[data-object~="autocomplete"]').hide()
  if $(element).val() in ['date', 'time']
    $('[data-object~="date-or-time"]').show()
  else
    $('[data-object~="date-or-time"]').hide()
  if $(element).val() in ['checkbox', 'radio']
    $('[data-object~="checkbox-or-radio"]').show()
  else
    $('[data-object~="checkbox-or-radio"]').hide()
  if $(element).val() in ['scale']
    $('[data-object~="scale"]').show()
  else
    $('[data-object~="scale"]').hide()
  if $(element).val() in ['calculated', 'integer', 'numeric', 'string']
    $('[data-object~="prepend-append"]').show()
  else
    $('[data-object~="prepend-append"]').hide()


@checkForBlankOptions = () ->
  blank_options = $('[data-object~="option-name"]').filter( () ->
    $.trim($(this).val()) == ''
  )
  blank_options.parent().parent().addClass('error')
  unless $('#variable_variable_type').val() not in ['dropdown', 'checkbox', 'radio'] or blank_options.size() == 0 or confirm('Options with blank names will be removed. Proceed anyways?')
    return false
  true

# Sets color for all ranges
@checkAllRanges = () ->
  $.each($('[data-object~="minmax"]'), () -> setRange($(this)))
  $.each($('[data-object~="dateminmax"]'), () -> setRangeDate($(this)))

@setRange = (el) ->
  el.removeClass('error-input warning-input')
  if ($.trim(el.val()) not in el.data('missing-codes')) and ((isNaN(parseInt($.trim(el.val()))) and $.trim(el.val()).length > 0) or parseInt($.trim(el.val())) < parseInt(el.data('hard-minimum')) or parseInt($.trim(el.val())) > parseInt(el.data('hard-maximum')))
    el.addClass('error-input')
  else if ($.trim(el.val()) not in el.data('missing-codes')) and ((isNaN(parseInt($.trim(el.val()))) and $.trim(el.val()).length > 0) or parseInt($.trim(el.val())) < parseInt(el.data('soft-minimum')) or parseInt($.trim(el.val())) > parseInt(el.data('soft-maximum')))
    el.addClass('warning-input')

@checkMinMax = () ->
  $('[data-object~="minmax"]').parent().parent().removeClass('error')
  number_fields = $('[data-object~="minmax"]').filter( () ->
    # value is not in missing_codes and ()
    ($.trim($(this).val()) not in $(this).data('missing-codes')) and ((isNaN(parseInt($.trim($(this).val()))) and $.trim($(this).val()).length > 0) or parseInt($.trim($(this).val())) < parseInt($(this).data('hard-minimum')) or parseInt($.trim($(this).val())) > parseInt($(this).data('hard-maximum')))
  )
  number_fields.parent().parent().addClass('error')
  if number_fields.size() > 0
    alert('Some numeric fields are out of range!')
    return false
  true

@checkSoftMinMax = () ->
  $('[data-object~="minmax"]').parent().parent().removeClass('warning')
  number_fields = $('[data-object~="minmax"]').filter( () ->
    ($.trim($(this).val()) not in $(this).data('missing-codes')) and ((isNaN(parseInt($.trim($(this).val()))) and $.trim($(this).val()).length > 0) or parseInt($.trim($(this).val())) < parseInt($(this).data('soft-minimum')) or parseInt($.trim($(this).val())) > parseInt($(this).data('soft-maximum')))
  )
  number_fields.parent().parent().addClass('warning')
  if number_fields.size() > 0 and !confirm('Some numeric fields are out of the recommended range. Proceed anyways?')
    return false
  true

@setRangeDate = (el) ->
  el.removeClass('error-input warning-input')
  if ($.trim(el.val()) not in el.data('missing-codes')) and ((isNaN(Date.parse($.trim(el.val()))) and $.trim(el.val()).length > 0) or Date.parse($.trim(el.val())) < Date.parse(el.data('date-hard-minimum')) or Date.parse($.trim(el.val())) > Date.parse(el.data('date-hard-maximum')))
    el.addClass('error-input')
  else if ($.trim(el.val()) not in el.data('missing-codes')) and ((isNaN(Date.parse($.trim(el.val()))) and $.trim(el.val()).length > 0) or Date.parse($.trim(el.val())) < Date.parse(el.data('date-soft-minimum')) or Date.parse($.trim(el.val())) > Date.parse(el.data('date-soft-maximum')))
    el.addClass('warning-input')

# Select dates that don't parse as dates, and are not blank
# or dates where the value is less than the hard minimum
# or dates where the value is greater than the hard maximum
@checkDateMinMax = () ->
  $('[data-object~="dateminmax"]').parent().parent().removeClass('error')
  date_fields = $('[data-object~="dateminmax"]').filter( () ->
    ($.trim($(this).val()) not in $(this).data('missing-codes')) and ((isNaN(Date.parse($.trim($(this).val()))) and $.trim($(this).val()).length > 0) or Date.parse($.trim($(this).val())) < Date.parse($(this).data('date-hard-minimum')) or Date.parse($.trim($(this).val())) > Date.parse($(this).data('date-hard-maximum')))
  )
  date_fields.parent().parent().addClass('error')
  if date_fields.size() > 0
    alert('Some dates are out of range!')
    return false
  true

@checkSoftDateMinMax = () ->
  $('[data-object~="dateminmax"]').parent().parent().removeClass('warning')
  date_fields = $('[data-object~="dateminmax"]').filter( () ->
    ($.trim($(this).val()) not in $(this).data('missing-codes')) and ((isNaN(Date.parse($.trim($(this).val()))) and $.trim($(this).val()).length > 0) or Date.parse($.trim($(this).val())) < Date.parse($(this).data('date-soft-minimum')) or Date.parse($.trim($(this).val())) > Date.parse($(this).data('date-soft-maximum')))
  )
  date_fields.parent().parent().addClass('warning')
  if date_fields.size() > 0 and !confirm('Some dates are out of the recommended range. Proceed anyways?')
    return false
  true

# Ex: parseValue('ess1', 'integer', '')
#     parseValue('gender', 'string', '')
#     parseValue('bmi', 'float', '')
# grid_string is used to specify a specific location in the grid

@parseValue = (variable_name, format_type, grid_string) ->
  elements = $("[data-name='#{variable_name}']#{grid_string}")
  checked = ''
  checked = ':checked' if elements.data('variable-type') == 'radio'
  element = $("[data-name='#{variable_name}']#{grid_string}#{checked}")
  if format_type == 'integer'
    parseInt($(element).val())
  else if format_type == 'float'
    parseFloat($(element).val())
  else
    $(element).val()

@updateCalculatedVariables = () ->
  $.each($('[data-object~="calculated"]'), () ->
    # alert($(this).data('calculation'))
    calculation = $(this).data('calculation')
    grid_position = $(this).data('grid-position')
    # calculation = calculation.replace(/([\w]+)/g, "parseInt($('[data-name=\"\$1\"]').val())");
    if calculation
      grid_string = ''
      if grid_position != '' and grid_position != null and grid_position != undefined
        grid_string = '[data-grid-position="' + grid_position + '"]'
      # calculation = calculation.replace(/([a-zA-Z]+[\w]*)/g, "parseFloat($('[data-name=\"\$1\"]#{grid_string}').val())")
      calculation = calculation.replace(/([a-zA-Z]+[\w]*)/g, "parseValue('\$1', 'float', '#{grid_string}')")
      calculation_result = eval(calculation)
      $.get(root_url + 'projects/' + $("#sheet_project_id").val() + '/variables/' + $(this).data('variable-id') + '/format_number', 'calculated_number=' + calculation_result + '&location_id=' + $(this).data('location-id') + '&sheet_authentication_token=' + ($('#sheet_authentication_token').val() || ""), null, "script")

    # $(this).val(calculation_result)
    # $($(this).data('target')).html(calculation_result)
  )

jQuery ->
  $(document)
    .on('click', '#add_more_options', () ->
      $.post(root_url + 'projects/' + $("#variable_project_id").val() + '/variables/add_option', $("form").serialize() + "&_method=post", null, "script")
      false
    )
    .on('click', '#add_more_domain_options', () ->
      $.post(root_url + 'projects/' + $("#domain_project_id").val() + '/domains/add_option', $("form").serialize() + "&_method=post", null, "script")
      false
    )

  $(document)
    .on('change', '#variable_variable_type', () -> toggleOptions($(this)))
    .on('change', '#variable_domain_id', () ->
      $.post(root_url + 'projects/' + $("#variable_project_id").val() + '/domains/values', "domain_id=#{$(this).val()}", null, "script")
      false
    )

  if $('#variable_variable_type')
    toggleOptions($('#variable_variable_type'));

  $('#options[data-object~="sortable"]').sortable( placeholder: "well alert alert-block" )

  $(document).on('click', '[data-object~="form-check-before-submit"]', () ->
    if checkForBlankOptions() == false
      return false
    $($(this).data('target')).submit()
    false
  )

  $(document)
    .on('click', '[data-object~="variable-check-before-submit"]', () ->
      if checkMinMax() == false
        return false
      if checkDateMinMax() == false
        return false
      if checkSoftMinMax() == false
        return false
      if checkSoftDateMinMax() == false
        return false
      window.$isDirty = false
      if $(this).data('page')?
        $('#current_design_page').val($(this).data('page'))
      if $(this).data('continue')?
        $('#continue').val($(this).data('continue'))
      $('[data-object~="variable-check-before-submit"]').attr('disabled', 'disabled')
      $($(this).data('target')).submit()
      false
    )
    .on('click', '[data-object~="update-variable"]', () ->
      $.post($($(this).data('target')).attr('action'), $($(this).data('target')).serialize() + "&_method=put", null, "script")
    )
    .on('click', '[data-object~="popup-variable"]', () ->
      position = $(this).data('position')
      variable_id = $('#design_option_tokens_' + position + '_variable_id').val()
      if variable_id
        $.get(root_url + 'projects/' + $("#design_project_id").val() + '/variables/' + variable_id + '/edit', 'position=' + position, null, "script")
      else
        $.get(root_url + 'projects/' + $("#design_project_id").val() + '/variables/new', 'position=' + position, null, "script")
      false
    )
    .on('change', '[data-object~="variable-load"]', () ->
      position = $(this).data('position')
      retrieveVariable(position)
      false
    )
    .on('click', '#add_grid_variable', () ->
      position = $(this).data('position')
      $.post(root_url + 'projects/' + $("#variable_project_id").val() + '/variables/add_grid_variable', 'position=' + position, null, "script")
      false
    )
    .on('click', '[data-object~="grid-row-add"]', () ->
      variable_id = $(this).data('variable-id')
      $.post(root_url + 'projects/' + $("#sheet_project_id").val() + '/variables/' + variable_id + '/add_grid_row', 'sheet_authentication_token=' + ($('#sheet_authentication_token').val() || ""), null, "script")
      false
    )
    .on('click', '[data-object~="set-current-time"]', () ->
      currentTime = new Date()
      day = currentTime.getDate()
      month = currentTime.getMonth() + 1
      year = currentTime.getFullYear()
      hours = currentTime.getHours()
      minutes = currentTime.getMinutes()

      minutes = "0" + minutes if minutes < 10
      month = "0" + month if month < 10
      day = "0" + day if day < 10

      $($(this).data('target-time')).val(hours+":"+minutes+":00")
      $($(this).data('target-date')).val(month + "/" + day + "/" + year)
      $($(this).data('target-time')).change()
      $($(this).data('target-date')).change()
      false
    )
    .on('click', '[data-object~="clear-radio"]', () ->
      group_name = $(this).data('group')
      $(":radio[name='" + group_name + "']").prop('checked', false)
      updateAllVariables()
      updateCalculatedVariables()
      false
    )
    .on('click', '[data-object~="clear-checkbox"]', () ->
      group_name = $(this).data('group')
      $(":checkbox[name='" + group_name + "']").removeAttr('checked')
      updateAllVariables()
      updateCalculatedVariables()
      false
    )
    .on('click', '[data-object~="set-variable-type"]', () ->
      $("#variable_type").val($(this).data('value'))
      $($(this).data('target')).submit()
    )
    .on('click', '[data-object~="show-graph"]', () ->
      drawScatter($(this).data('target'), eval($(this).data('data')), $(this).data('title'), $(this).data('y-axis-title'), $(this).data('x-axis-title'), $(this).data('units'))
      false
    )
    .on('change', '[data-object~="minmax"]', () ->
      setRange($(this))
    )
    .on('change', '[data-object~="dateminmax"]', () ->
      setRangeDate($(this))
    )
