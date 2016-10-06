$(document)
  .on('click', "[data-object~='submit-ae-comment']", ->
    $(this).attr('disabled', 'disabled')
    $("#{$(this).data('target')} #adverse_event_comment_comment_type").val($(this).data('comment-type'))
    $($(this).data('target')).submit()
    false
  )
  .on('keyup', "[data-object~='ae-comment-comment-field']", ->
    if $(this).val().trim() == ''
      $('#reopen-ae-button').html('Reopen AE Report')
      $('#close-ae-button').html('Close AE Report')
    else
      $('#reopen-ae-button').html('Reopen and comment')
      $('#close-ae-button').html('Close and comment')
  )
