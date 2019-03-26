# This function updates all variables starting with lowest one and progressing
# up in visibility.
@updateAllDesignOptionsVisibility = ->
  $('[data-object~="design-option-container"]').each( (index, variableContainer) ->
    updateDesignOptionContainer(variableContainer)
  )
  $('[data-object~="design-option-scale-header"]').each( (index, element) ->
    if elementVisible(element)
      $(element).show()
    else
      $(element).hide()
  )
  false

@updateAlternatingVariableClasses = ->
  $('.variable-visible').each( (index, element) ->
    if index % 2 == 0
      $(element).removeClass('variable-blind')
      $(element).addClass('variable-shade')
    else
      $(element).removeClass('variable-shade')
      $(element).addClass('variable-blind')
  )

# This function updates an individual variables container to show or be hidden
# based on what variable it depends on.
@updateDesignOptionContainer = (element) ->
  if elementVisible(element)
    $(element).show()
    $(element).addClass('variable-visible') if $(element).hasClass('form-group') and not $(element).hasClass('calculation-hidden')
  else
    $(element).hide()
    $(element).removeClass('variable-visible')
  updateAlternatingVariableClasses()

@buildDesignOption = (element) ->
  design_option = {}
  design_option.position = element.data('position')
  return design_option

@hideInteractiveDesignModal = ->
  $('#interactive_design_modal').modal('hide')

@showInteractiveDesignModal = ->
  $('#interactive_design_modal').modal('show')

$(document)
  .on("click", "[data-object~=section-insert]", ->
    $.ajax(
      url: $(this).data("url")
      type: $(this).data("method")
      data: {}
      success: null
      dataType: "script"
    )
    false
  )
  .on('click', '[data-object~="new-variable-popup"]', ->
    project_id = $("#project_id").val()
    design_id = $('#design_id').val()
    changes = {}
    changes.design_option = buildDesignOption($(this))
    changes.variable = { variable_type: $(this).data('variable-type') }
    $.get("#{root_url}projects/#{project_id}/designs/#{design_id}/design_options/new_variable", changes, null, "script")
    false
  )
  .on('click', '[data-object~="new-existing-variable-popup"]', ->
    project_id = $("#project_id").val()
    design_id = $('#design_id').val()
    changes = {}
    changes.design_option = buildDesignOption($(this))
    $.get("#{root_url}projects/#{project_id}/designs/#{design_id}/design_options/new_existing_variable", changes, null, "script")
    false
  )
  .on('click', '[data-object~="set-variable-domain"]', ->
    project_id = $("#project_id").val()
    design_id = $('#design_id').val()
    design_option_id = $(this).data('design-option-id')
    changes = {}
    changes['_method'] = 'patch' if changes != null
    changes['variable'] = { domain_id: $($(this).data('target')).val() }
    $.post("#{root_url}projects/#{project_id}/designs/#{design_id}/design_options/#{design_option_id}", changes, null, "script")
  )
