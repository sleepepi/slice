$(document)
  # This collapses the menu on mobile devices after clicking a link in it.
  .on('click', '[data-object~="remove-collapse-in"]', ->
    $($(this).data('target')).removeClass('in')
  )
