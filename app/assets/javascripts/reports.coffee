@setScrollShadow = (element) ->
  if $(element).scrollLeft() == 0
    $(element).removeClass("shadow-inset-left")
  else
    $(element).addClass("shadow-inset-left")

  if $(element).scrollLeft() >= $(element).children().width() - $(element).width()
    $(element).removeClass("shadow-inset-right")
  else
    $(element).addClass("shadow-inset-right")
  false

@submitReportWithFilters = ->
  filters = $("#filters_form").serialize()
  $.post($("#report_form").attr('action'), filters + '&' + $("#report_form").serialize(), null, 'script')

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
    else
      $(this).peity($(this).data('type'))
  )

@reportsReady = ->
  loadPeity()

$(document)
  .on('click', '[data-object~="set-percent"], [data-object~="set-by"], [data-object~="set-filter"]', (e) ->
    $(this).find('input').prop('checked', true)
    submitReportWithFilters()
    e.preventDefault()
  )
  .on('click', '[data-object~="export-report-pdf"]', ->
    window.open($($(this).data('target')).attr('action') + '.pdf?orientation=' + $(this).data('orientation') + '&' + $($(this).data('target')).serialize())
    false
  )
  .on('click', '[data-object~="export-report-pdf-with-filters"]', ->
    window.open($($(this).data('target')).attr('action') + '.pdf?orientation=' + $(this).data('orientation') + '&' + $($(this).data('target')).serialize() + '&' + $('#filters_form').serialize())
    false
  )
  .on('click', '[data-object~="export-csv-with-filters"]', ->
    url = $($(this).data('target')).attr('action') + '.' + $(this).data('format') + '?' + $($(this).data('target')).serialize() + '&' + $('#filters_form').serialize()
    if $(this).data('page') == 'blank'
      window.open(url)
    else
      window.location = url
    false
  )
  .on('click', '[data-object~="set-value"]', ->
    $($(this).data('target')).val($(this).data('value'))
    submitReportWithFilters()
    false
  )
  .on('click', '[data-object~="refresh-report"]', ->
    submitReportWithFilters()
    false
  )
