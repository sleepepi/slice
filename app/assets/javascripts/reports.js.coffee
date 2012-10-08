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
    .on('change', '[data-object~="form-reload"]', () ->
      $($(this).data('target')).submit()
    )
    .on('click', '[data-object~="export-report-pdf"]', () ->
      window.location = $($(this).data('target')).attr('action') + '_print.pdf?' + $($(this).data('target')).serialize()
      false
    )

  $('#column_variable_id').on('change', () ->
    if $(this).val() == '' or $(this).val() == null
      $('#column-include-blank').hide()
      $('#column-by-time').show()
    else
      $('#column-by-time').hide()
      $('#column-include-blank').show()
  )

  $('#variable_id').on('change', () ->
    if $(this).val() == '' or $(this).val() == null
      $('#row-include-blank').hide()
    else
      $('#row-include-blank').show()
  )
