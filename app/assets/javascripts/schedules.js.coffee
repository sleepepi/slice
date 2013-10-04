# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
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

  $('#items_container[data-object~="sortable"]').sortable( placeholder: "well alert alert-block" )
