jQuery ->
  # <a href='#' data-object="remove" data-target="abc"></a>
  # <div id="abc">
  # Removes a data-target id when a node with data-object="remove" is clicked
  $(document).on('click', '[data-object~="remove"]', () ->
    $('#' + $(this).data('target')).remove()
    false
  )

  # Move to Contour
  $(document).on('click', '[data-object~="order"]', () ->
    $('#order').val($(this).data('order'))
    $($(this).data('form')).submit()
    false
  )
