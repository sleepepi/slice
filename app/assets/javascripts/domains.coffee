# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

@activateDomainOptions = () ->
  $('#options[data-object~="sortable"]').sortable( placeholder: "well alert alert-block", update: ( event, ui ) -> setDomainOptionPlaceholders() )
  setDomainOptionPlaceholders()

@setDomainOptionPlaceholders = () ->
  if $('#is_new_domain').val() == '1'
    $("[name='domain[option_tokens][][value]']").each( (index, element) ->
      $(element).val("#{index + 1}")
      $(element).parent().hide()
    )
    $("[name='domain[option_tokens][][name]']").each( (index, element) ->
      $(element).parent().removeClass('col-xs-4')
      $(element).parent().addClass('col-xs-6')
    )
  else
    $("[name='domain[option_tokens][][value]']").each( (index, element) ->
      $(element).attr('placeholder', "#{index + 1}")
    )
  $("[name='domain[option_tokens][][name]']").each( (index, element) ->
    $(element).attr('placeholder', "Option #{index + 1}")
  )

@domainsReady = () ->
  activateDomainOptions()

$(document)
  .on('click', '#add_more_domain_options', () ->
    $.post(root_url + 'projects/' + $("#domain_project_id").val() + '/domains/add_option', $("form").serialize() + "&_method=post", null, "script")
    false
  )
  .on('keyup', '[data-object~="create-domain-name"]', () ->
    new_value = $(this).val().replace(/[^a-zA-Z0-9]/g, '_').toLowerCase()
    new_value = new_value.replace(/^[\d_]/i, 'n').replace(/_{2,}/g, '_').replace(/_$/, '').substring(0,30)
    $($(this).data('domain-target')).val(new_value)
  )
  .on('click', '[data-object~="domain-form-submit"]', () ->
    if $(this).data('continue')?
      $('#continue').val($(this).data('continue'))
    $($(this).data('target')).submit()
    false
  )
