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
  if $(element).val() in ['date', 'time_of_day']
    $('[data-object~="date-or-time-of-day"]').show()
  else
    $('[data-object~="date-or-time-of-day"]').hide()
  if $(element).val() in ['time_of_day']
    $('[data-object~="time-of-day"]').show()
  else
    $('[data-object~="time-of-day"]').hide()
  if $(element).val() in ['time_duration']
    $('[data-object~="time-duration"]').show()
  else
    $('[data-object~="time-duration"]').hide()
  if $(element).val() in ['checkbox', 'radio']
    $('[data-object~="checkbox-or-radio"]').show()
  else
    $('[data-object~="checkbox-or-radio"]').hide()
  if $(element).val() in ['calculated', 'integer', 'numeric', 'string']
    $('[data-object~="prepend-append"]').show()
  else
    $('[data-object~="prepend-append"]').hide()


@checkForBlankOptions = ->
  blank_options = $('[data-object~="option-name"]').filter( ->
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
  variable_type = elements.data('variable-type')
  checked = ''
  checked = ':checked' if variable_type in ['radio', 'checkbox']
  elements = $("[data-name='#{variable_name}']#{grid_string}#{checked}")
  vals = []
  $.each(elements, ->
    if format_type == 'integer'
      vals.push parseInt($(this).val())
    else if format_type == 'float'
      vals.push parseFloat($(this).val())
    else
      vals.push $(this).val()
  )
  if variable_type == 'checkbox'
    vals
  else
    vals[0]

@getDesignVariableAuthenticationParams = (element) ->
  changes = {}
  changes.design = $(element).data('design')
  changes.variable_id = $(element).data('variable-id')
  changes.handoff = $(element).data('handoff')
  return changes

@updateCalculatedVariables = ->
  $.each($('[data-object~="calculated"]'), ->
    calculation = $(this).data('calculation')
    grid_position = $(this).data('grid-position')
    if calculation
      grid_string = ''
      if grid_position != '' and grid_position != null and grid_position != undefined
        grid_string = '[data-grid-position="' + grid_position + '"]'
      calculation = calculation.replace(/([a-zA-Z]+[\w]*)/g, ($1) ->
        if $1 == 'overlap'
          'overlap'
        else
          "parseValue('#{$1}', 'float', '#{grid_string}')"
      )
      calculation_result = eval(calculation)
      calculation_result = '' unless isNumber(calculation_result)
      target_name = $(this).data('target-name')
      $("##{target_name}").val(calculation_result)
      $("##{target_name}_calculation_result").val(calculation_result)
  )

@variableAutocompleteReady = ->
  $('[data-object~="variable-name-autocomplete"]').each(->
    $this = $(this)
    $this.textcomplete(
      [
        {
          match: /(^|\s)has\:([\w\-]*)$/
          search: (term, callback) ->
            words = ['adverse-events', 'comments', 'files']
            resp = $.map(words, (word) ->
              if word.indexOf(term) == 0
                word
              else
                null
            )
            callback(resp)
          replace: (value) -> return "$1has:#{value}"
        },
        {
          match: /(^|\s)checks\:([\w\-]*)$/
          search: (term, callback) ->
            $.getJSON("#{root_url}projects/#{$this.data('project-id')}/variables/checks_search", { q: term })
              .done((resp) -> callback(resp) )
              .fail(-> callback([]))
          replace: (value) ->
            return "$1checks:#{value}"
          cache: true
        },
        {
          match: /(^|\s)events\:([\w\-]*)$/
          search: (term, callback) ->
            $.getJSON("#{root_url}projects/#{$this.data('project-id')}/variables/events_search", { q: term })
              .done((resp) -> callback(resp) )
              .fail(-> callback([]))
          replace: (value) ->
            return "$1events:#{value}"
          cache: true
        },
        {
          match: /(^|\s)(\w+)$/
          search: (term, callback) ->
            $.getJSON("#{root_url}projects/#{$this.data('project-id')}/variables/search", { q: term })
              .done((resp) -> callback(resp))
              .fail(-> callback([]))
          replace: (value) ->
            return "$1#{value}"
          cache: true
        },
        {
          match: /(^|\s)(\w+\:[^\s]*)$/
          search: (term, callback) ->
            $.getJSON("#{root_url}projects/#{$this.data('project-id')}/variables/values_search", { q: term })
              .done((resp) -> callback(resp) )
              .fail(-> callback([]))
          replace: (item) ->
            return "$1#{item.value}"
          template: (item) ->
            if item.name?
              "#{item.name}"
            else
              "#{item.value}"
          cache: true
        }
      ], { appendTo: 'body' }
    )
  )

@variablesReady = ->
  if $('#variable_variable_type')
    toggleOptions($('#variable_variable_type'))
  variableAutocompleteReady()

$(document)
  .on('change', '#variable_variable_type', -> toggleOptions($(this)))
  .on('change', '#variable_domain_id', ->
    project_id = $(this).data('project-id')
    domain_id = $(this).val()
    $.post("#{root_url}projects/#{project_id}/domains/values", "domain_id=#{domain_id}", null, 'script')
    false
  )
  .on('click', '[data-object~="form-check-before-submit"]', ->
    if checkForBlankOptions() == false
      return false
    if $(this).data('continue')?
      $('#continue').val($(this).data('continue'))
    $($(this).data('target')).submit()
    false
  )
  .on('click', '[data-object~="variable-check-before-submit"]', ->
    $('[data-object~="variable-check-before-submit"]').prop('disabled', true)
    $('[data-object~="variable-check-before-submit"]').attr('disabled', 'disabled')
    window.$isDirty = false
    $($(this).data('target')).submit()
    false
  )
  .on('click', '[data-object~="update-variable"]', ->
    $.post($($(this).data('target')).attr('action'), $($(this).data('target')).serialize() + "&_method=put", null, "script")
  )
  .on('click', '[data-object~="popup-variable"]', ->
    position = $(this).data('position')
    variable_id = $('#design_option_tokens_' + position + '_variable_id').val()
    if variable_id
      $.get(root_url + 'projects/' + $("#design_project_id").val() + '/variables/' + variable_id + '/edit', 'position=' + position, null, "script")
    else
      $.get(root_url + 'projects/' + $("#design_project_id").val() + '/variables/new', 'position=' + position, null, "script")
    false
  )
  .on('change', '[data-object~="variable-load"]', ->
    position = $(this).data('position')
    retrieveVariable(position)
    false
  )
  .on('click', '#add_grid_variable', ->
    $.post("#{root_url}projects/#{$(this).data('project-id')}/variables/add_grid_variable", null, null, 'script')
    false
  )
  .on('click', '[data-object~="grid-row-add"]', ->
    changes = getDesignVariableAuthenticationParams(this)
    changes.design_option_id = $(this).data('design-option-id')
    changes.header = $(this).data('header')
    $.post("#{root_url}external/add_grid_row", changes, null, "script")
    false
  )
  .on('click', '[data-object~="set-current-time"]', ->
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
  .on('click', '[data-object~="set-variable_type"]', ->
    $(this).find('input').prop('checked', true)
    $('#variables_search').submit()
  )
  .on('keyup', '[data-object~="create-variable-name"]', ->
    new_value = $(this).val().replace(/[^a-zA-Z0-9]/g, '_').toLowerCase()
    new_value = new_value.replace(/^[\d_]/i, 'n').replace(/_{2,}/g, '_').replace(/_$/, '').substring(0,32)
    $($(this).data('variable-name-target')).val(new_value)
  )
  .on('change', '.upload', ->
    file_name = this.value.replace(/\\/g, '/').replace(/.*\//, '')
    $(this).parent().find('.file-input-display').html( file_name || 'Upload File' )
  )
