jQuery ->
  # <a href='#' data-object="remove" data-target="abc"></a>
  # <div id="abc">
  # Removes a data-target id when a node with data-object="remove" is clicked
  $(document).on('click', '[data-object~="remove"]', () ->
    plural = if $(this).data('count') == 1 then '' else 's'
    if $(this).data('count') in [0, null] or ($(this).data('count') and confirm('Removing this option will PERMANENTLY ERASE DATA you have collected. Are you sure you want to RESET responses that used this option from ' + $(this).data('count') + ' sheet' + plural +  '?'))
      $('#' + $(this).data('target')).remove()
      false
    else
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

  $(document).on('click', '[data-object~="reset-filters"]', () ->
    $('[data-object~="filter"]').val('')
    $($(this).data('target')).submit()
    false
  )

