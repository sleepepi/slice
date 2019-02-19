@toggleOptions = (element) ->
  $('[data-object~="options"]').hide()
  $('[data-object~="range"]').hide()
  $('[data-object~="date"]').hide()
  $('[data-object~="calculated"]').hide()
  $('[data-object~="grid"]').hide()
  $('[data-object~="calculated-or-number"]').hide()
  $('[data-object~="autocomplete"]').hide()
  $('[data-object~="date-or-time-of-day"]').hide()
  $('[data-object~="time-of-day"]').hide()
  $('[data-object~="time-duration"]').hide()
  $('[data-object~="checkbox-or-radio"]').hide()
  $('[data-object~="prepend-append"]').hide()
  $('[data-object~="options"]').show() if $(element).val() in ['dropdown', 'checkbox', 'radio', 'integer', 'numeric']
  $('[data-object~="prepend-append"]').show() if $(element).val() in ['calculated', 'integer', 'numeric', 'string']
  $('[data-object~="calculated-or-number"]').show() if $(element).val() in ['calculated', 'integer', 'numeric']
  $('[data-object~="checkbox-or-radio"]').show() if $(element).val() in ['checkbox', 'radio']
  $('[data-object~="range"]').show() if $(element).val() in ['integer', 'numeric', 'imperial_height', 'imperial_weight']
  $('[data-object~="date-or-time-of-day"]').show() if $(element).val() in ['date', 'time_of_day']
  $('[data-object~="calculated"]').show() if $(element).val() in ['calculated']
  $('[data-object~="date"]').show() if $(element).val() in ['date']
  $('[data-object~="grid"]').show() if $(element).val() in ['grid']
  $('[data-object~="autocomplete"]').show() if $(element).val() in ['string']
  $('[data-object~="time-duration"]').show() if $(element).val() in ['time_duration']
  $('[data-object~="time-of-day"]').show() if $(element).val() in ['time_of_day']

@checkForBlankOptions = ->
  blank_options = $('[data-object~="option-name"]').filter( ->
    $(this).val().trim() == ""
  )
  blank_options.parent().parent().addClass('has-error')
  unless $('#variable_variable_type').val() not in ['dropdown', 'checkbox', 'radio'] or blank_options.size() == 0 or confirm('Options with blank names will be removed. Proceed anyways?')
    return false
  true

@isNumber = (n) ->
  !isNaN(parseFloat(n)) && isFinite(n)

# Ex: parseValue(ess1_id, 'integer', '')
#     parseValue(gender_id, 'string', '')
#     parseValue(bmi_id, 'float', '')
# grid_string is used to specify a specific location in the grid
@parseValueByID = (variable_id, format_type, grid_string) ->
  elements = $("[data-calculation-id='#{variable_id}']#{grid_string}")
  variable_type = elements.data('variable-type')
  checked = ''
  checked = ':checked' if variable_type in ['radio', 'checkbox']
  elements = $("[data-calculation-id='#{variable_id}']#{grid_string}#{checked}")
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
  params = {}
  params.project_id = $(element).data("project-id")
  params.design = $(element).data("design")
  params.variable_id = $(element).data("variable-id")
  params.handoff = $(element).data("handoff")
  params.assignment_id = $(element).data("assignment-id")
  return params

@updateCalculatedVariables = ->
  $.each($("[data-object~=calculated]"), ->
    calculation = $(this).data("calculation")
    grid_position = $(this).data("grid-position")

    # TODO: Do full calculation server-side
    if calculation
      grid_string = ""
      if grid_position != "" and grid_position != null and grid_position != undefined
        grid_string = '[data-grid-position="' + grid_position + '"]'
      calculation = calculation.replace(/\#{(\d+)}/g, "parseValueByID('$1', 'float', '#{grid_string}')")
      calculation_result = eval(calculation)
      calculation_result = "" unless isNumber(calculation_result)
      target_name = $(this).data("target-name")
      $("##{target_name}").val(calculation_result)

      params = {}
      params.value = calculation_result

      $.ajax(
        url: $(this).data("format-url")
        type: "POST"
        dataType: "json"
        data: params
      ).done( (data) ->
        $("##{target_name}_calculation_result").val(data["value"]["formatted"])
      ).fail( (jqXHR, textStatus, errorThrown) ->
        console.log("FAIL: #{textStatus} #{errorThrown}")
      )
  )

@calculationTextcompleteReady = ->
  $('[data-object~="calculation-variable-name-textcomplete"]').each(->
    $this = $(this)
    $this.textcomplete(
      [
        {
          match: /(^|\s)(\w+)$/
          search: (term, callback) ->
            $.getJSON("#{root_url}projects/#{$this.data('project-id')}/variables/search", { q: term })
              .done((resp) -> callback(resp))
              .fail(-> callback([]))
          replace: (value) ->
            return "$1#{value}"
          cache: true
        }
      ],
      zIndex: 1060
    )
  )

@variablesReady = ->
  if $('#variable_variable_type')
    toggleOptions($('#variable_variable_type'))
  calculationTextcompleteReady()


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
  .on("click", "[data-object~=grid-row-add]", ->
    params = getDesignVariableAuthenticationParams(this)
    params.design_option_id = $(this).data("design-option-id")
    params.header = $(this).data("header")
    params.language = $("[name=language]").val()
    $.post("#{root_url}external/add_grid_row", params, null, "script")
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
