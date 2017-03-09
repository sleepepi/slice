@eventsReady = ->
  $('#designs[data-object~="sortable"]').sortable(
    handle: ".design-handle"
  )

$(document)
  .on('change', '[data-object~="event-design-requirement"]', ->
    if $(this).val() == 'conditional'
      $($(this).data('target')).show()
    else
      $($(this).data('target')).hide()
  )
