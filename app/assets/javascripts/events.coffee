@eventsReady = ->
  $('#designs[data-object~="sortable"]').sortable(
    handle: ".design-handle"
  )
