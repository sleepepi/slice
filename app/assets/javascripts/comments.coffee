@resetSubmitButtons = () ->
  $('[data-object~="comment-submit"]').removeAttr('disabled')

$(document)
  .on('click', '[data-object~="comment-submit"]', () ->
    $(this).attr('disabled', 'disabled')
    $($(this).data('target')).submit()
    false
  )
