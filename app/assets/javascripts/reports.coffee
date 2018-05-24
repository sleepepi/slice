@loadPeity = ->
  $.each($('[data-object~="sparkline"]'), ->
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
    else if $(this).data('type') == 'pie'
      $(this).sparkline($(this).data('values'),
        type: $(this).data('type')
      )
    else if $(this).data('type') == 'bar'
      $(this).sparkline($(this).data('values'),
        type: $(this).data('type')
      )
    else
      $(this).peity($(this).data('type'))
  )

@reportsReady = ->
  loadPeity()
