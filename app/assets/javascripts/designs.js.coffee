# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

@retrieveVariable = (position) ->
  variable_id = $('#design_option_tokens_' + position + '_variable_id').val()
  if variable_id
    $.get(root_url + 'variables/' + variable_id, 'position=' + position, null, "script")
  false

@toggleCondition = (element) ->
  conditional_variable_id = $(element).attr('id')
  # + $(element).val()
  selector = '[data-condition-parent~="' + conditional_variable_id + '"]'
  $(selector).each( (index, el) ->
    if String($(element).val()) == String($(el).data('condition-value'))
      $(el).show()
    else
      $(el).hide()
  )
  false


jQuery ->
  $('#add_more_variables').on('click', () ->
    $.post(root_url + 'designs/add_variable', $("form").serialize() + "&_method=post", null, "script")
    false
  )

  $('#variables[data-object~="sortable"]').sortable( placeholder: "well alert alert-block" )

  $(document).on('change', '[data-object~="condition"]', () ->
    toggleCondition($(this))
  )

  # $('[data-object~="variable-load"]').change( () ->
  #   retrieveVariable($(this).data('position'))
  #   false
  # )

