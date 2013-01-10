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
    )
    .on('click', '[data-object~="set-by"]', () ->
      $("#by").val($(this).data('value'))
      $("#report_form").submit()
    )
    .on('click', '[data-object~="set-filter"]', () ->
      $("#filter").val($(this).data('value'))
      $("#report_form").submit()
    )
    .on('click', '[data-object~="set-statuses"]', () ->
      if $(this).hasClass('active')
        $("#statuses_#{$(this).data('value')}").val('')
      else
        $("#statuses_#{$(this).data('value')}").val($(this).data('value'))
      $($(this).data('target')).submit()
    )
    .on('change', '[data-object~="form-reload"]', () ->
      $($(this).data('target')).submit()
    )
    .on('click', '[data-object~="export-report-pdf"]', () ->
      window.location = $($(this).data('target')).attr('action') + '_print.pdf?orientation=' + $(this).data('orientation') + '&' + $($(this).data('target')).serialize()
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
