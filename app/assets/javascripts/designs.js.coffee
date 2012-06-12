# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

@retrieveVariable = (position) ->
  variable_id = $('#design_option_tokens_' + position + '_variable_id').val()
  if variable_id
    $.get(root_url + 'variables/' + variable_id, 'position=' + position, null, "script")
  false


jQuery ->
  $('#add_more_variables').on('click', () ->
    $.post(root_url + 'designs/add_variable', $("form").serialize() + "&_method=post", null, "script")
    false
  )

  $('#variables[data-object~="sortable"]').sortable( placeholder: "well alert alert-block" )

  # $('[data-object~="variable-load"]').change( () ->
  #   retrieveVariable($(this).data('position'))
  #   false
  # )

