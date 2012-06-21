# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

@retrieveVariable = (position) ->
  variable_id = $('#design_option_tokens_' + position + '_variable_id').val()
  if variable_id
    $.get(root_url + 'variables/' + variable_id, 'position=' + position, null, "script")
  false

@intersection = (a, b) ->
  [a, b] = [b, a] if a.length > b.length
  value for value in a when value in b

@dmsg = (message) ->
  # $('#error_log').prepend('<li style="margin-left:' + window.indentcount + '00px">' + message + '</li>')
  false


@toggleCondition = (element) ->
  dmsg("Checking Locked #{$(element).attr('id')} Locked: '#{$(element).data('locked')}'")
  if $(element).data('locked') == 1
    dmsg("Skipping #{$(element).attr('id')}")
    return false
  $(element).data('locked', 1)
  dmsg("Locking #{$(element).attr('id')}")
  window.indentcount = window.indentcount + 1
  conditional_variable_id = $(element).data('condition-target')
  selector = '[data-condition-parent~="' + conditional_variable_id + '"]'
  $(selector).each( (index, el) ->
    if $(element).is(':hidden')
      $(el).hide()
      dmsg("Hiding #{$(el).attr('id')}")
    else if $(element).is(':checkbox, :radio')
      values = []
      $.each($("input[name='" + $(element).attr('name') + "']:checked"), () ->
        values.push($(this).val())
      )
      if intersection(values, String($(el).data('condition-value')).split(',')).length > 0
        $(el).show()
        dmsg("Showing #{$(el).attr('id')}")
      else
        $(el).hide()
        dmsg("Hiding #{$(el).attr('id')}")
    else
      if String($(element).val()) in String($(el).data('condition-value')).split(',')
        $(el).show()
        dmsg("Showing #{$(el).attr('id')}")
      else
        $(el).hide()
        dmsg("Hiding #{$(el).attr('id')}")
    $(el).find('[data-object~="condition"]').change()
  )
  window.indentcount = window.indentcount - 1
  dmsg("Unlocking #{$(element).attr('id')}")
  dmsg("")
  $(element).data('locked', 0)
  false


jQuery ->
  window.indentcount = 0

  $('#add_more_variables').on('click', () ->
    $.post(root_url + 'designs/add_variable', $("form").serialize() + "&_method=post", null, "script")
    false
  )

  $('#add_more_sections').on('click', () ->
    $.post(root_url + 'designs/add_section', $("form").serialize() + "&_method=post", null, "script")
    false
  )

  $('#add_more_variables_top').on('click', () ->
    $.post(root_url + 'designs/add_variable', $("form").serialize() + "&location=top&_method=post", null, "script")
    false
  )

  $('#add_more_sections_top').on('click', () ->
    $.post(root_url + 'designs/add_section', $("form").serialize() + "&location=top&_method=post", null, "script")
    false
  )

  $('#variables[data-object~="sortable"]').sortable( placeholder: "well alert alert-block" )

  $(document)
    .on('change', '[data-object~="condition"]', () ->
      toggleCondition($(this))
    )
    .on('click', '[data-object~="expand-details"]', () ->
      $('[data-object~="' + $(this).data('selector') + '"]').hide()
      $($(this).data('target')).show()
      false
    )


  # $('[data-object~="variable-load"]').change( () ->
  #   retrieveVariable($(this).data('position'))
  #   false
  # )

