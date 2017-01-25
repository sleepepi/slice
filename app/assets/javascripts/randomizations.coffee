@loadRandomizationsByMonth = ->
  Highcharts.setOptions(
    lang:
      thousandsSep: ','
    colors: ['#7cb5ec', '#90ed7d', '#f7a35c', '#8085e9',
      '#f15c80', '#e4d354', '#2b908f', '#f45b5b', '#91e8e1']
  )
  if $('[data-object~="draw-chart"]').length > 0
    $.each($('[data-object~=draw-chart]'), ->
      $(@).highcharts(
        credits:
          enabled: false
        chart:
          backgroundColor: null
          zoomType: 'x'
        title:
          text: $(@).data('title')
        subtitle:
          text: (if document.ontouchstart == undefined then 'Click and drag in the plot area to zoom in' else 'Pinch the chart to zoom in')
          style:
            color: '#999'
        xAxis:
          categories: $(@).data('categories')
          title:
            text: $(@).data('xaxis')
        yAxis:
          min: 0
          minTickInterval: 1
          title:
            text: $(@).data('yaxis')
          # labels:
          #   formatter: -> return bytes(this.value, true, 0)
        # tooltip:
        #   formatter: -> return bytes(this.y, true, 1)
        plotOptions:
          column:
            pointPadding: 0.2
            borderWidth: 0
            # stacking: 'normal'
        series: $(@).data('series')
      )
    )

@randomizationsTypeahead = ->
  $("[data-object~='randomization_subject_search']").typeahead('destroy')
  $("[data-object~='randomization_subject_search']").each( ->
    $this = $(this)
    bloodhound = new Bloodhound(
      datumTokenizer: Bloodhound.tokenizers.obj.whitespace('value')
      queryTokenizer: Bloodhound.tokenizers.whitespace
      remote:
        url: "#{root_url}projects/#{$this.data('project-slug')}/schemes/#{$this.data('randomization-scheme-id')}/subject_search?q=%QUERY"
        wildcard: '%QUERY'
    )
    $this.typeahead({ hint: true },
      display: 'value'
      source: bloodhound
      templates:
        suggestion: (item) -> return "<div><strong>#{item.subject_code}</strong> <span class=\"label label-#{item.status_class}\">#{item.status}</span></div>"
    )
  )

@randomizationsReady = ->
  randomizationsTypeahead()
  loadRandomizationsByMonth()

@checkRandomizationOption = (element) ->
  $(element).prop('checked', true)
  updateSelectedClass($(element).attr('name'))

@randomizationTermSelected = (element, event, datum) ->
  checkRandomizationOption("#stratification_factors_#{$(element).data('sfo-id')}_#{datum['site_id']}")
  $.each(datum['stratification_factors'], (key, value) ->
    radio_input = "[data-stratification-factor-id=#{key}][data-value=#{value}]"
    checkRandomizationOption(radio_input)
  )

$(document)
  .on('typeahead:selected', "[data-object~='randomization_subject_search']", (event, datum) ->
    randomizationTermSelected(@, event, datum)
  )
  .on('typeahead:autocompleted', "[data-object~='randomization_subject_search']", (event, datum) ->
    randomizationTermSelected(@, event, datum)
  )
