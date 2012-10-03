jQuery ->
  # <a href='#' data-object="remove" data-target="abc"></a>
  # <div id="abc">
  # Removes a data-target id when a node with data-object="remove" is clicked

  $(document).on('focus', "select[rel~=tooltip], input[rel~=tooltip], textarea[rel~=tooltip]", () -> $(this).tooltip( trigger: 'focus' ))

  $(document)
    .on('click', '[data-object~="remove"]', () ->
      plural = if $(this).data('count') == 1 then '' else 's'
      if $(this).data('count') in [0, undefined] or ($(this).data('count') and confirm('Removing this option will PERMANENTLY ERASE DATA you have collected. Are you sure you want to RESET responses that used this option from ' + $(this).data('count') + ' sheet' + plural +  '?'))
        $('#' + $(this).data('target')).remove()
        false
      else
        false
    )
    .on('click', '[data-object~="modal-hide"]', () ->
      $($(this).data('target')).modal('hide');
      false
    )
    .on('click', '[data-object~="submit"]', () ->
      $($(this).data('target')).submit();
      false
    )
    .on('click', '[data-object~="reset-filters"]', () ->
      $('[data-object~="filter"]').val('')
      $('[data-object~="filter-html"]').html('')
      $($(this).data('target')).submit()
      false
    )
    .on('click', '[data-object~="suppress-click"]', () ->
      false
    )

  $("[rel~=popover]").popover( offset: 10, trigger: 'focus' )

  $("span[rel~=tooltip]").tooltip( trigger: 'hover' )

  window.$isDirty = false
  msg = 'You haven\'t saved your changes.'

  $(document).on('change', ':input', () ->
    if $("#isdirty").val() == '1'
      window.$isDirty = true
  )

  $(document).ready( () ->
    window.onbeforeunload = (el) ->
      if window.$isDirty
        return msg
  )
