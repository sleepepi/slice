# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

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

@disablePushPartialChangeButtons = () ->
  $("#interactive-design-container [data-object~='push-partial-change']").attr('disabled', 'disabled')

@resetPushPartialChangeButtons = () ->
  $("#interactive-design-container [data-object~='push-partial-change']").removeAttr('disabled')

@pushPartialChangeWithFile = (element) ->
  if $("#section_section_type").is(":checked")
    section_type = 1
  else
    section_type = 0

  formData = new FormData()

  formData.append("section[section_name]", $("#section_section_name").val())
  formData.append("section[section_description]", $("#section_section_description").val())
  formData.append("section[section_image]", $("#section_section_image").prop("files")[0])
  formData.append("section[section_branching_logic]", $("#section_section_branching_logic").val()) unless $("#section_section_branching_logic").val() == undefined
  formData.append("section[section_type]", section_type)

  formData.append("position", $(element).data('position')) unless $(element).data('position') == undefined
  formData.append("variable_id", $(element).data('variable-id')) unless $(element).data('variable-id') == undefined
  formData.append("create", $(element).data('create')) unless $(element).data('create') == undefined
  formData.append("update", $(element).data('update')) unless $(element).data('update') == undefined
  formData.append("delete", $(element).data('delete')) unless $(element).data('delete') == undefined

  $.ajax(
    url: root_url + 'projects/' + $("#project_id").val() + '/designs/' + $('#design_id').val()
    type: 'PUT'
    data: formData
    cache: false
    contentType: false
    processData: false
  )

@pushPartialChange = (element) ->
  disablePushPartialChangeButtons()
  design_id = parseInt($('#design_id').val())
  changes = null
  if $($(element).data('target')).length > 0
    params = $($(element).data('target')).serialize()
    params = params + "&position=" + $(element).data('position') unless $(element).data('position') == undefined
    params = params + "&variable_id=" + $(element).data('variable-id') unless $(element).data('variable-id') == undefined
    params = params + "&create=" + $(element).data('create') unless $(element).data('create') == undefined
    params = params + "&update=" + $(element).data('update') unless $(element).data('update') == undefined
    params = params + "&delete=" + $(element).data('delete') unless $(element).data('delete') == undefined
  else
    changes = $(element).data('changes') || {}
    changes.position = $(element).data('position')
    changes.variable_id = $(element).data('variable-id')
    changes.create = $(element).data('create')
    changes.update = $(element).data('update')
    changes.delete = $(element).data('delete')
  if design_id > 0
    changes['_method'] = 'put' if changes != null
    params = params + "&_method=put"
    $.post(root_url + 'projects/' + $("#project_id").val() + '/designs/' + $('#design_id').val(), changes || params, null, "script")
  else
    $.post(root_url + 'projects/' + $("#project_id").val() + '/designs', changes || params, null, "script")

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
  $(".active[data-object~='edit-mode'],.active[data-object~='preview-mode']").click();

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
  .on('keypress', '[data-object~="push-partial-change-text-field"]', (e) ->
    if e.which == 13 # Enter
      pushPartialChange(this)
      e.preventDefault()
  )
  .on('click', '[data-object~="push-partial-change"]', () ->
    pushPartialChange(this)
    false
  )
  .on('keypress', '[data-object~="push-partial-change-with-file-text-field"]', (e) ->
    if e.which == 13 # Enter
      pushPartialChangeWithFile(this)
      e.preventDefault()
  )
  .on('click', '[data-object~="push-partial-change-with-file"]', () ->
    pushPartialChangeWithFile(this)
    false
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


