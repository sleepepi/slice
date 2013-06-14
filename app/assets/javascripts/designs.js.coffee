# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

# This function updates all variables starting with lowest one and progressing up in visibility.
# After hiding or showing all the variables, it updates the scroll-spy to correct any offsets that may
# have been introduced
@updateAllVariables = () ->
  variableContainers = $('[data-object~="variable-container"]')
  variableContainers.each( (index, variableContainer) ->
    updateVariableContainer(variableContainer)
  )
  $('[data-spy="scroll"]').each( () ->
    $spy = $(this).scrollspy('refresh')
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

@toggleReorderDesignSubmitButton = () ->
  rows = $.map($('#compact_design').sortable('toArray'), (val, i) -> parseInt(val.replace('option_', '')))
  if rows.toString() == rows.sort((a,b) -> a - b).toString()
    $('#reorder_design_button').attr('disabled', 'disabled')
  else
    $('#reorder_design_button').removeAttr('disabled')
  false

@toggleReorderSectionsSubmitButton = () ->
  sections = $.map($('#reorder_sections_design').sortable('toArray'), (val, i) -> parseInt(val.replace('section_', '')))
  if sections.toString() == sections.sort((a,b) -> a - b).toString()
    $('#reorder_design_sections_button').attr('disabled', 'disabled')
  else
    $('#reorder_design_sections_button').removeAttr('disabled')
  false

@initializeDesignReordering = () ->
  $('#compact_design[data-object~="sortable"]').sortable(
    placeholder: "li-section li-placeholder"
    stop: () ->
      toggleReorderDesignSubmitButton()
      true
  )
  $('#reorder_sections_design[data-object~="sortable"]').sortable(
    placeholder: "li-section li-placeholder"
    stop: () ->
      toggleReorderSectionsSubmitButton()
      true
  )

@loadVariableSortable = () ->
  $('#variables[data-object~="sortable"]').sortable(
    placeholder: "well alert alert-block"
    handle: ".handle"
    cursorAt:
      top: 30
  )

jQuery ->

  loadVariableSortable()

  $('#form_grid_variables[data-object~="sortable"]').sortable( placeholder: "well alert alert-block" )

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
      $($(this).data('target')).val(new_value)
    )
    .on('click', '[data-object~="pull-partial-edit"]', () ->
      design_id = parseInt($('#design_id').val())
      changes = $(this).data('changes') || {}
      changes.new = $(this).data('new')
      changes.edit = $(this).data('edit')
      changes.position = $(this).data('position')
      changes.variable_id = $(this).data('variable-id')
      changes.variable_type = $(this).data('variable-type')
      if design_id > 0
        $.get(root_url + 'projects/' + $("#project_id").val() + '/designs/' + $('#design_id').val() + '/edit', changes, null, "script")
      else
        $.get(root_url + 'projects/' + $("#project_id").val() + '/designs/new', changes, null, "script")
      false
    )
    .on('click', '[data-object~="push-partial-change"]', () ->
      design_id = parseInt($('#design_id').val())
      changes = null
      if $($(this).data('target')).length > 0
        params = $($(this).data('target')).serialize()
        params = params + "&position=" + $(this).data('position') unless $(this).data('position') == undefined
        params = params + "&variable_id=" + $(this).data('variable-id') unless $(this).data('variable-id') == undefined
        params = params + "&create=" + $(this).data('create') unless $(this).data('create') == undefined
        params = params + "&update=" + $(this).data('update') unless $(this).data('update') == undefined
        params = params + "&delete=" + $(this).data('delete') unless $(this).data('delete') == undefined
      else
        changes = $(this).data('changes') || {}
        changes.position = $(this).data('position')
        changes.variable_id = $(this).data('variable-id')
        changes.create = $(this).data('create')
        changes.update = $(this).data('update')
        changes.delete = $(this).data('delete')
      if design_id > 0
        changes['_method'] = 'put' if changes != null
        params = params + "&_method=put"
        $.post(root_url + 'projects/' + $("#project_id").val() + '/designs/' + $('#design_id').val(), changes || params, null, "script")
      else
        $.post(root_url + 'projects/' + $("#project_id").val() + '/designs', changes || params, null, "script")
      false
    )
    .on('click', '#reorder_design_button', () ->
      if $(this).attr('disabled') != 'disabled'
        $('#reorder_design_button, #reorder_design_sections_button').attr('disabled', 'disabled')
        rows = $('#compact_design').sortable('toArray').toString()
        $.post($('#reorder_design_form').attr('action'), '&rows='+rows, null, 'script')
        $('#saving_modal').modal(backdrop: 'static', keyboard: false)
      false
    )
    .on('click', '#reorder_design_sections_button', () ->
      if $(this).attr('disabled') != 'disabled'
        $('#reorder_design_button, #reorder_design_sections_button').attr('disabled', 'disabled')
        sections = $('#reorder_sections_design').sortable('toArray').toString()
        $.post($('#reorder_sections_design_form').attr('action'), '&sections='+sections, null, 'script')
        $('#saving_modal').modal(backdrop: 'static', keyboard: false)
      false
    )
    .on('click', '#sections_link', () ->
      $(this).closest('li').addClass('disabled')
      $('#variables_link').closest('li').removeClass('disabled')
      $('#reorder_design_button, #compact_design_container').hide()
      $('#reorder_design_sections_button, #reorder_sections_container').show()
      false
    )
    .on('click', '#variables_link', () ->
      $(this).closest('li').addClass('disabled')
      $('#sections_link').closest('li').removeClass('disabled')
      $('#reorder_design_button, #compact_design_container').show()
      $('#reorder_design_sections_button, #reorder_sections_container').hide()
      false
    )
    .on('click', '[data-object~="preview-mode"]', () ->
      $('.design-preview-hide').hide()
    )
    .on('click', '[data-object~="edit-mode"]', () ->
      $('.design-preview-hide').show()
    )

  initializeDesignReordering()

  $("#form_grid_variables div").last().click()

  if $('[data-object~="ajax-timer"]').length > 0
    interval = setInterval( () ->
      $('[data-object~="ajax-timer"]').each( () ->
        $.post($(this).data('path'), "interval=#{interval}", null, "script")
      )
    , 5000)

