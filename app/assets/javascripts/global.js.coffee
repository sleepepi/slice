jQuery ->
  # <a href='#' data-object="remove" data-target="abc"></a>
  # <div id="abc">
  # Removes a data-target id when a node with data-object="remove" is clicked
  $(document).on('click', '[data-object~="remove"]', () ->
    $('#' + $(this).data('target')).remove()
    false
  )

  $(document).on('click', '[data-object~="modal-hide"]', () ->
    $($(this).data('target')).modal('hide');
    false
  )

  $(document).on('click', '[data-object~="submit"]', () ->
    $($(this).data('target')).submit();
    false
  )
