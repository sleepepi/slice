# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

@submitReportWithFilters = () ->
  filters = $("#filters_form").serialize()
  $.post($("#report_form").attr('action'), filters + '&' + $("#report_form").serialize(), null, 'script')

@loadPeity = () ->
  $.each($('[data-object~="sparkline"]'), () ->
    $(this).show()
    if $(this).data('type') == 'box'
      minValue = undefined
      minValue = parseInt($(this).data('min')) unless isNaN(parseInt($(this).data('min')))
      maxValue = undefined
      maxValue = parseInt($(this).data('max')) unless isNaN(parseInt($(this).data('max')))

      $(this).sparkline($(this).data('values'),
        type: $(this).data('type')
        chartRangeMin: minValue
        chartRangeMax: maxValue
      )
    else
      $(this).peity($(this).data('type'))
  )

jQuery ->
  $(document)
    .on('click', '[data-object~="set-percent"]', () ->
      $("#percent").val($(this).data('value'))
      # $("#report_form").submit()
    )
    .on('click', '[data-object~="set-by"]', () ->
      $("#by").val($(this).data('value'))
      # $("#report_form").submit()
    )
    .on('click', '[data-object~="set-filter"]', () ->
      $("#filter").val($(this).data('value'))
      # $("#report_form").submit()
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
      window.open($($(this).data('target')).attr('action') + '_print.pdf?orientation=' + $(this).data('orientation') + '&' + $($(this).data('target')).serialize())
      false
    )
    .on('change', '#row_variable_temp_ids', (event, value) ->
      values = if $('#row_variable_ids').val() == '' then [] else $('#row_variable_ids').val().split(',')
      if value['selected']
        values.push(value['selected']) if $.inArray(value['selected'], values) == -1
      if value['deselected']
        position = $.inArray(value['deselected'], values)
        values.splice(position,1).pop(value['deselected']) if position >= 0
      $('#row_variable_ids').val(values.join(','))
      $('#report_form').submit()
    )
    .on('click', '[data-object~="set-value"]', () ->
      $($(this).data('target')).val($(this).data('value'))
      $("#report_form").submit()
      false
    )

  $('#variable_id').on('change', () ->
    if $(this).val() == '' or $(this).val() == null
      $('#row-include-blank').hide()
    else
      $('#row-include-blank').show()
  )

  loadPeity()
