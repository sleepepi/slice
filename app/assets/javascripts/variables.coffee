@toggleOptions = (element) ->
  if $(element).val() in ['dropdown', 'checkbox', 'radio', 'integer', 'numeric']
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
  if $(element).val() in ['calculated', 'integer', 'numeric', 'string']
    $('[data-object~="prepend-append"]').show()
  else
    $('[data-object~="prepend-append"]').hide()


@checkForBlankOptions = () ->
  blank_options = $('[data-object~="option-name"]').filter( () ->
    $.trim($(this).val()) == ''
  )
  blank_options.parent().parent().addClass('has-error')
  unless $('#variable_variable_type').val() not in ['dropdown', 'checkbox', 'radio'] or blank_options.size() == 0 or confirm('Options with blank names will be removed. Proceed anyways?')
    return false
  true

# Ex: parseValue('ess1', 'integer', '')
#     parseValue('gender', 'string', '')
#     parseValue('bmi', 'float', '')
# grid_string is used to specify a specific location in the grid

@isNumber = (n) ->
  !isNaN(parseFloat(n)) && isFinite(n)

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
    calculation = $(this).data('calculation')
    grid_position = $(this).data('grid-position')
    if calculation
      grid_string = ''
      if grid_position != '' and grid_position != null and grid_position != undefined
        grid_string = '[data-grid-position="' + grid_position + '"]'
      calculation = calculation.replace(/([a-zA-Z]+[\w]*)/g, "parseValue('\$1', 'float', '#{grid_string}')")
      calculation_result = eval(calculation)
      calculation_result = '' unless isNumber(calculation_result)
      $.get(root_url + 'projects/' + $("#sheet_project_id").val() + '/variables/' + $(this).data('variable-id') + '/format_number', 'calculated_number=' + calculation_result + '&target_name=' + $(this).data('target-name') + '&sheet_authentication_token=' + ($('#sheet_authentication_token').val() || ""), null, "script")
  )

@variablesReady = () ->
  if $('#variable_variable_type')
    toggleOptions($('#variable_variable_type'))

$(document)
  .on('change', '#variable_variable_type', () -> toggleOptions($(this)))
  .on('change', '#variable_domain_id', () ->
    $.post(root_url + 'projects/' + $("#variable_project_id").val() + '/domains/values', "domain_id=#{$(this).val()}", null, "script")
    false
  )
  .on('click', '[data-object~="form-check-before-submit"]', () ->
    if checkForBlankOptions() == false
      return false
    if $(this).data('continue')?
      $('#continue').val($(this).data('continue'))
    $($(this).data('target')).submit()
    false
  )
  .on('click', '[data-object~="variable-check-before-submit"]', () ->
    window.$isDirty = false
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
    header = $(this).data('header')
    $.post(root_url + 'projects/' + $("#sheet_project_id").val() + '/variables/' + variable_id + '/add_grid_row', 'sheet_authentication_token=' + ($('#sheet_authentication_token').val() || "") + '&header=' + header, null, "script")
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
    $($(this).data('target-date').replace('#', '#month_')).val(month)
    $($(this).data('target-date').replace('#', '#day_')).val(day)
    $($(this).data('target-date').replace('#', '#year_')).val(year)
    $($(this).data('target-time')).change()
    $($(this).data('target-date')).change()
    false
  )
  .on('click', '[data-object~="set-variable_type"]', () ->
    $(this).find('input').prop('checked', true)
    $('#variables_search').submit()
  )
  .on('change', '.upload', () ->
    file_name = this.value.replace(/\\/g, '/').replace(/.*\//, '')
    $(this).parent().find('.file-input-display').html( file_name || 'Upload File' )
  )
