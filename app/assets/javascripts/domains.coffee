@activateDomainOptions = ->
  $('#options[data-object~="sortable"]').sortable( placeholder: "well alert alert-block", update: ( event, ui ) -> setDomainOptionPlaceholders() )
  setDomainOptionPlaceholders()

@setDomainOptionPlaceholders = ->
  if $('#is_new_domain').val() == '1'
    $("[name='domain[option_tokens][][value]']").each( (index, element) ->
      $(element).val("#{index + 1}")
      $(element).parent().hide()
    )
  else
    $("[name='domain[option_tokens][][value]']").each( (index, element) ->
      $(element).attr('placeholder', "#{index + 1}")
    )
  if $("[name=language]").val() == "en"
    $("[name='domain[option_tokens][][name]']").each( (index, element) ->
      $(element).attr('placeholder', "Option #{index + 1}")
    )

@domainsReady = ->
  activateDomainOptions()

$(document)
  .on('click', '#add_more_domain_options', ->
    $.post("#{root_url}projects/#{$(@).data('project-id')}/domains/add_option", null, null, "script")
    false
  )
  .on('keyup', '[data-object~="create-domain-name"]', ->
    new_value = $(this).val().replace(/[^a-zA-Z0-9]/g, '_').toLowerCase()
    new_value = new_value.replace(/^[\d_]/i, 'n').replace(/_{2,}/g, '_').replace(/_$/, '').substring(0,30)
    $($(this).data('domain-target')).val(new_value)
  )
  .on('click', '[data-object~="domain-form-submit"]', ->
    if $(this).data('continue')?
      $('#continue').val($(this).data('continue'))
    $($(this).data('target')).submit()
    false
  )
