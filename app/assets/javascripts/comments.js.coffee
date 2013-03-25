# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@resetSubmitButtons = () ->
  $('[data-object~="comment-submit"]').removeAttr('disabled')

jQuery ->
  $(document)
    .on('click', '[data-object~="comment-submit"]', () ->
      $(this).attr('disabled', 'disabled')
      $($(this).data('target')).submit()
      false
    )
