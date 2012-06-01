# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

@toggleOptions = (element) ->
  if $(element).val() in ['dropdown', 'checkbox', 'radio']
    $('[data-object~="options"]').show()
  else
    $('[data-object~="options"]').hide()

@checkForBlankOptions = () ->
  blank_options = $('[data-object~="option-name"]').filter( () ->
    $.trim($(this).val()) == ''
  )
  blank_options.parent().parent().addClass('error')
  unless blank_options.size() == 0 or confirm('Options with blank names will be removed. Proceed anyways?')
    return false
  true

jQuery ->
  $('#add_more_options').on('click', () ->
    $.post(root_url + 'variables/add_option', $("form").serialize() + "&_method=post", null, "script")
    false
  )

  $(document)
    .on('change', '#variable_variable_type', () -> toggleOptions($(this)))

  $('#options[data-object~="sortable"]').sortable( placeholder: "well alert alert-block" )

  $(document).on('click', '[data-object~="form-check-before-submit"]', () ->
    if checkForBlankOptions() == false
      return false
    $($(this).data('target')).submit()
    false
  )
