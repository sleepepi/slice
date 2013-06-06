# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/


# This function updates all variables starting with lowest one and progressing up in visibility.
# After hiding or showing all the variables, it updates the scroll-spy to correct any offsets that may
# have been introduced
@updateAllVariables = () ->
  variableContainers = $('[data-object~="variable-container"]')
  # dmsg("Updating #{variableContainers.length} Variables")
  # $(variableContainers.get().reverse()).each( (index, variableContainer) ->
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
      # alert branching_logic
      branching_logic_result = eval(branching_logic)
    catch error
      alert('Error in branching logic syntax.' + error)
      branching_logic_result = true
    if branching_logic_result
      truth_table.push(1)
    else
      truth_table.push(0)


  # dmsg truth_table
  if 0 in truth_table
    $(element).hide()
    dmsg("Hiding #{$(element).attr('id')}")
  else
    $(element).show()
    dmsg("Showing #{$(element).attr('id')}")
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

# TODO REMOVE BELOW
@dmsg = (message) ->
  # $('#error_log').prepend('<li>' + message + '</li>')
  false

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

  $('#add_more_variables').on('click', () ->
    $.post(root_url + 'projects/' + $("#design_project_id").val() + '/designs/add_variable', $("form").serialize() + "&_method=post", null, "script")
    false
  )

  $('#add_more_sections').on('click', () ->
    $.post(root_url + 'projects/' + $("#design_project_id").val() + '/designs/add_section', $("form").serialize() + "&_method=post", null, "script")
    false
  )

  $('#add_more_variables_top').on('click', () ->
    $.post(root_url + 'projects/' + $("#design_project_id").val() + '/designs/add_variable', $("form").serialize() + "&location=top&_method=post", null, "script")
    false
  )

  $('#add_more_sections_top').on('click', () ->
    $.post(root_url + 'projects/' + $("#design_project_id").val() + '/designs/add_section', $("form").serialize() + "&location=top&_method=post", null, "script")
    false
  )

  loadVariableSortable()

  $('#form_grid_variables[data-object~="sortable"]').sortable( placeholder: "well alert alert-block" )

  $('#reorder_design_button').on('click', () ->
    if $(this).attr('disabled') != 'disabled'
      $('#reorder_design_button, #reorder_design_sections_button').attr('disabled', 'disabled')
      rows = $('#compact_design').sortable('toArray').toString()
      $.post($('#reorder_design_form').attr('action'), '&rows='+rows, null, 'script')
      $('#saving_modal').modal(backdrop: 'static', keyboard: false)
    false
  )

  $('#reorder_design_sections_button').on('click', () ->
    if $(this).attr('disabled') != 'disabled'
      $('#reorder_design_button, #reorder_design_sections_button').attr('disabled', 'disabled')
      sections = $('#reorder_sections_design').sortable('toArray').toString()
      $.post($('#reorder_sections_design_form').attr('action'), '&sections='+sections, null, 'script')
      $('#saving_modal').modal(backdrop: 'static', keyboard: false)
    false
  )

  $('#sections_link').on('click', () ->
    $(this).closest('li').addClass('disabled')
    $('#variables_link').closest('li').removeClass('disabled')
    $('#reorder_design_button, #compact_design_container').hide()
    $('#reorder_design_sections_button, #reorder_sections_container').show()
    false
  )

  $('#variables_link').on('click', () ->
    $(this).closest('li').addClass('disabled')
    $('#sections_link').closest('li').removeClass('disabled')
    $('#reorder_design_button, #compact_design_container').show()
    $('#reorder_design_sections_button, #reorder_sections_container').hide()
    false
  )

  $(document)
    .on('change', '[data-object~="condition"]', () ->
      updateAllVariables()
      updateCalculatedVariables()
    )
    .on('click', '[data-object~="expand-details"]', () ->
      $('[data-object~="' + $(this).data('inverse-selector') + '"]').show()
      $('[data-object~="' + $(this).data('selector') + '"]').hide()
      $($(this).data('target')).show()
      $($(this).data('target-hide')).hide()
    )
    .on('click', '[data-object~="variable-insert-after"]', () ->
      $.post(root_url + 'projects/' + $("#design_project_id").val() + '/designs/add_variable', $("form").serialize() + "&location=" + $(this).data('position') + "&_method=post", null, "script")
      false
    )
    .on('click', '[data-object~="section-insert-after"]', () ->
      $.post(root_url + 'projects/' + $("#design_project_id").val() + '/designs/add_section', $("form").serialize() + "&location=" + $(this).data('position') + "&_method=post", null, "script")
      false
    )
    .on('click', '[data-object~="copy-repeatables"]', () ->
      parent = $(this)
      val = $($($(this).data('target')).get().reverse()).each( () ->
        parent.after($(this).html())
      )
      false
    )
    .on('mousedown', '.handle', () ->
      $($(this).closest('[data-object~="expand-details"]').data('target')).hide()
      $($(this).closest('[data-object~="expand-details"]').data('target-hide')).show()
    )
    .on('click', '[data-object~="click-and-show"]', () ->
      $.post($(this).data('path'), $('#design_id').serialize(), null, "script")
      false
    )
    .on('click', '[data-object~="partial-update-submit"]', () ->
      $(this).addClass('active') if $(this).parent().hasClass('btn-group')
      $.post($(this).data('path'), $('#design_id').serialize() + '&' + $($(this).data('target')).serialize(), null, "script")
      false
    )
    .on('click', '[data-object~="design-stop-edit"]', () ->
      design_id = parseInt($('#design_id').val())
      if design_id > 0
        window.location = $(this).data('path') + "/#{design_id}"
      else
        window.location = $(this).data('path')
      false
    )
    .on('keyup', '[data-object~="create-variable-name"]', () ->
      new_value = $(this).val().replace(/[^a-zA-Z0-9]/g, '_').toLowerCase()
      new_value = new_value.replace(/^[\d_]/i, 'n').replace(/_{2,}/g, '_').replace(/_$/, '').substring(0,32)
      $($(this).data('target')).val(new_value)
    )



  initializeDesignReordering()

  $("#variables div, #form_grid_variables div").last().click()

  if $('[data-object~="ajax-timer"]').length > 0
    interval = setInterval( () ->
      $('[data-object~="ajax-timer"]').each( () ->
        $.post($(this).data('path'), "interval=#{interval}", null, "script")
      )
    , 5000)

  # $('[data-object~="variable-load"]').change( () ->
  #   retrieveVariable($(this).data('position'))
  #   false
  # )

