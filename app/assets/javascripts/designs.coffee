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
  a = a.map(String)
  b = b.map(String)
  intersection(a, b).length >= c

@toggleReorderSubmitButton = (sortable_container, reorder_button) ->
  sortable_order = $(sortable_container).sortable('toArray', attribute: 'data-position')
  if sortable_order.toString() == sortable_order.sort((a,b) -> a - b).toString()
    $(reorder_button).attr('disabled', 'disabled')
  else
    $(reorder_button).removeAttr('disabled')
  false

@initializeDesignReordering = ->
  $('#reorder_options[data-object~="sortable"]').sortable(
    placeholder: 'li-section li-placeholder'
    handle: '.option-handle'
    stop: ->
      toggleReorderSubmitButton($(this), '#reorder_design_button')
      true
  )
  $('#reorder_sections_design[data-object~="sortable"]').sortable(
    placeholder: 'li-section li-placeholder'
    handle: '.option-handle'
    stop: ->
      toggleReorderSubmitButton($(this), '#reorder_design_sections_button')
      true
  )

@designsReady = ->
  $('#form_grid_variables[data-object~="sortable"]').sortable( placeholder: "well alert alert-block" )
  initializeDesignReordering()
  $("#form_grid_variables div").last().click()
  if $('[data-object~="ajax-timer"]').length > 0
    interval = setInterval( ->
      $('[data-object~="ajax-timer"]').each( ->
        $.post($(this).data('path'), "interval=#{interval}", null, "script")
      )
    , 5000)

$(document)
  .on('change', '[data-object~="condition"]', ->
    updateAllDesignOptionsVisibility()
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
  .on('click', '#reorder_design_button', ->
    if $(this).attr('disabled') != 'disabled'
      $('#reorder_design_button, #reorder_design_sections_button').attr('disabled', 'disabled')
      rows = $('#reorder_options').sortable('toArray', attribute: 'data-position').toString()
      $.post($('#reorder_design_form').attr('action'), '&rows='+rows, null, 'script')
      $('#saving_modal').modal(backdrop: 'static', keyboard: false)
    false
  )
  .on('click', '#reorder_design_sections_button', ->
    if $(this).attr('disabled') != 'disabled'
      $('#reorder_design_button, #reorder_design_sections_button').attr('disabled', 'disabled')
      sections = $('#reorder_sections_design').sortable('toArray', attribute: 'data-position').toString()
      $.post($('#reorder_sections_design_form').attr('action'), '&sections='+sections, null, 'script')
      $('#saving_modal').modal(backdrop: 'static', keyboard: false)
    false
  )
  .on('click', '#sections_link', ->
    $(this).closest('li').addClass('disabled')
    $('#variables_link').closest('li').removeClass('disabled')
    $('#reorder_design_button, #reorder_options_container').hide()
    $('#reorder_design_sections_button, #reorder_sections_container').show()
    false
  )
  .on('click', '#variables_link', ->
    $(this).closest('li').addClass('disabled')
    $('#sections_link').closest('li').removeClass('disabled')
    $('#reorder_design_button, #reorder_options_container').show()
    $('#reorder_design_sections_button, #reorder_sections_container').hide()
    false
  )
  .on("click", "[data-object~=preview-mode]", ->
    $(".design-preview-hide").hide()
    $("[data-object~=design-preview-expand]").removeClass("col-sm-6")
    $("[data-object~=design-preview-expand]").addClass("col-sm-12")
    $("[data-object~=edit-mode]").removeClass("active")
    $("[data-object~=preview-mode]").addClass("active")
    false
  )
  .on("click", "[data-object~=edit-mode]", ->
    $(".design-preview-hide").show()
    $("[data-object~=design-preview-expand]").removeClass("col-sm-12")
    $("[data-object~=design-preview-expand]").addClass("col-sm-6")
    $("[data-object~=preview-mode]").removeClass("active")
    $("[data-object~=edit-mode]").addClass("active")
    false
  )


