@schedulesReady = () ->
  $('#items_container[data-object~="sortable"]').sortable( placeholder: "well alert alert-block" )

$(document)
  .on('click', '[data-object~="expand-item-details"]', () ->
    $('[data-object~="' + $(this).data('selector') + '"]').hide()
    $($(this).data('target')).show()
  )
  .on('click', '[data-object~="noclickbubble"]', (event) ->
    event.cancelBubble = true
    event.stopPropagation() if event.stopPropagation
    false
  )
