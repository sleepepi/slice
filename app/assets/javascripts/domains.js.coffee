# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

@activateDomainOptions = () ->
  $('#options[data-object~="sortable"]').sortable( placeholder: "well alert alert-block", update: ( event, ui ) -> setDomainOptionPlaceholders() )
  setDomainOptionPlaceholders()

@setDomainOptionPlaceholders = () ->
  $("[name='domain[option_tokens][][value]']").each( (index, element) ->
    $(element).attr('placeholder', "#{index + 1}")
  )
  $("[name='domain[option_tokens][][name]']").each( (index, element) ->
    $(element).attr('placeholder', "Option #{index + 1}")
  )

jQuery ->
  activateDomainOptions()

  $(document)
    .on('click', '#add_more_domain_options', () ->
      $.post(root_url + 'projects/' + $("#domain_project_id").val() + '/domains/add_option', $("form").serialize() + "&_method=post", null, "script")
      false
    )
