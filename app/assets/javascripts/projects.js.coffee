# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
  $.each($('[data-object~="peity"]'), () ->
    $(this).peity($(this).data('method'))
    $(this).show()
  )

  $(document)
    .on('click', '[data-object~="set-percent"]', () ->
      $("#percent").val($(this).data('value'))
      $("#report_form").submit()
      false
    )
    .on('click', '[data-object~="set-by"]', () ->
      $("#by").val($(this).data('value'))
      $("#report_form").submit()
      false
    )
