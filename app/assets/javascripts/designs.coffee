@showInteractiveDesignModal = () ->
  $('#interactive_design_modal').modal('show')

@hideInteractiveDesignModal = () ->
  $('#interactive_design_modal').modal('hide')


# This function updates all variables starting with lowest one and progressing up in visibility.
@updateAllVariables = () ->
  variableContainers = $('[data-object~="variable-container"]')
  variableContainers.each( (index, variableContainer) ->
    updateVariableContainer(variableContainer)
  )
  false

# This function updates an individual variables container to show or be hidden based on what variable keys it depends on.
# Show if none of the values evaluate to false [1,1,1,1] or [], but not [1,0,1,1] or [0]
@updateVariableContainer = (element) ->
  truth_table = []

  branching_logic = $(element).data('branching-logic') || ''

  if branching_logic != ''
    try
      branching_logic_result = eval(branching_logic)
    catch error
      alert('Error in branching logic syntax.' + error)
      branching_logic_result = true
    if branching_logic_result
      truth_table.push(1)
    else
      truth_table.push(0)

  if 0 in truth_table
    $(element).hide()
  else
    $(element).show()
  true

@retrieveVariable = (position) ->
  variable_id = $('#design_option_tokens_' + position + '_variable_id').val()
  if variable_id
    $("#variable_#{position}_edit_link").html("Edit")
    $.get(root_url + 'projects/' + $("#design_project_id").val() + '/variables/' + variable_id, 'position=' + position, null, "script")
  else
    $("#variable_#{position}_edit_link").html("Create")
  false

@intersection = (a, b) ->
  [a, b] = [b, a] if a.length > b.length
  value for value in a when value in b

@overlap = (a, b, c = 1) ->
  intersection(a, b).length >= c

@toggleReorderSubmitButton = (sortable_container, reorder_button) ->
  sortable_order = $(sortable_container).sortable('toArray', attribute: 'data-position')
  if sortable_order.toString() == sortable_order.sort((a,b) -> a - b).toString()
    $(reorder_button).attr('disabled', 'disabled')
  else
    $(reorder_button).removeAttr('disabled')
  false

@initializeDesignReordering = () ->
  $('#reorder_options[data-object~="sortable"]').sortable(
    placeholder: "li-section li-placeholder"
    stop: () ->
      toggleReorderSubmitButton($(this), '#reorder_design_button')
      true
  )
  $('#reorder_sections_design[data-object~="sortable"]').sortable(
    placeholder: "li-section li-placeholder"
    stop: () ->
      toggleReorderSubmitButton($(this), '#reorder_design_sections_button')
      true
  )

@loadVariableSortable = () ->
  $('#variables[data-object~="sortable"]').sortable(
    placeholder: "well alert alert-block"
    handle: ".handle"
    cursorAt:
      top: 30
  )

@designsReady = () ->
  loadVariableSortable()
  $('#form_grid_variables[data-object~="sortable"]').sortable( placeholder: "well alert alert-block" )
  initializeDesignReordering()

  $("#form_grid_variables div").last().click()

  if $('[data-object~="ajax-timer"]').length > 0
    interval = setInterval( () ->
      $('[data-object~="ajax-timer"]').each( () ->
        $.post($(this).data('path'), "interval=#{interval}", null, "script")
      )
    , 5000)
  $(".active[data-object~='edit-mode'],.active[data-object~='preview-mode']").click()

$(document)
  .on('change', '[data-object~="condition"]', () ->
    updateAllVariables()
    updateCalculatedVariables()
  )
  .on('click', '[data-object~="design-stop-edit"]', (e) ->
    design_id = parseInt($('#design_id').val())
    url = $(this).data('path')
    url += "/#{design_id}" if design_id > 0

    if nonStandardClick(e)
      window.open(url)
    else
      window.location = url
    false
  )
  .on('keyup', '[data-object~="create-variable-name"]', () ->
    new_value = $(this).val().replace(/[^a-zA-Z0-9]/g, '_').toLowerCase()
    new_value = new_value.replace(/^[\d_]/i, 'n').replace(/_{2,}/g, '_').replace(/_$/, '').substring(0,32)
    $($(this).data('variable-name-target')).val(new_value)
  )
  .on('click', '#reorder_design_button', () ->
    if $(this).attr('disabled') != 'disabled'
      $('#reorder_design_button, #reorder_design_sections_button').attr('disabled', 'disabled')
      rows = $('#reorder_options').sortable('toArray', attribute: 'data-position').toString()
      $.post($('#reorder_design_form').attr('action'), '&rows='+rows, null, 'script')
      $('#saving_modal').modal(backdrop: 'static', keyboard: false)
    false
  )
  .on('click', '#reorder_design_sections_button', () ->
    if $(this).attr('disabled') != 'disabled'
      $('#reorder_design_button, #reorder_design_sections_button').attr('disabled', 'disabled')
      sections = $('#reorder_sections_design').sortable('toArray', attribute: 'data-position').toString()
      $.post($('#reorder_sections_design_form').attr('action'), '&sections='+sections, null, 'script')
      $('#saving_modal').modal(backdrop: 'static', keyboard: false)
    false
  )
  .on('click', '#sections_link', () ->
    $(this).closest('li').addClass('disabled')
    $('#variables_link').closest('li').removeClass('disabled')
    $('#reorder_design_button, #reorder_options_container').hide()
    $('#reorder_design_sections_button, #reorder_sections_container').show()
    false
  )
  .on('click', '#variables_link', () ->
    $(this).closest('li').addClass('disabled')
    $('#sections_link').closest('li').removeClass('disabled')
    $('#reorder_design_button, #reorder_options_container').show()
    $('#reorder_design_sections_button, #reorder_sections_container').hide()
    false
  )
  .on('click', '[data-object~="preview-mode"]', () ->
    $('.design-preview-hide').hide()
    $('[data-object~="design-preview-expand"]').removeClass('col-sm-6')
    $('[data-object~="design-preview-expand"]').addClass('col-sm-12')
  )
  .on('click', '[data-object~="edit-mode"]', () ->
    $('.design-preview-hide').show()
    $('[data-object~="design-preview-expand"]').removeClass('col-sm-12')
    $('[data-object~="design-preview-expand"]').addClass('col-sm-6')
  )


