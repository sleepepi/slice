@loadRandomizationsByMonth = ->
  Highcharts.setOptions(
    lang:
      thousandsSep: ','
    colors: ['#7cb5ec', '#90ed7d', '#f7a35c', '#8085e9',
      '#f15c80', '#e4d354', '#2b908f', '#f45b5b', '#91e8e1']
  )
  if $('[data-object~="draw-chart"]').length > 0
    $.each($('[data-object~=draw-chart]'), () ->
      $(@).highcharts(
        credits:
          enabled: false
        chart:
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
          #   formatter: () -> return bytes(this.value, true, 0)
        # tooltip:
        #   formatter: () -> return bytes(this.y, true, 1)
        plotOptions:
          column:
            pointPadding: 0.2
            borderWidth: 0
            # stacking: 'normal'
        series: $(@).data('series')
      )
    )

@randomizationsReady = () ->
  $("[data-object~='randomization_subject_search']").each( () ->
    $this = $(this)
    $this.typeahead(
      remote: root_url + "projects/#{$this.data('project-slug')}/schemes/#{$this.data('randomization-scheme-id')}/subject_search?q=%QUERY"
      template: '<p><span class="label label-{{status_class}}">{{status}}</span> <strong>{{subject_code}}</strong></p>'
      engine: Hogan
    )
  )
  loadRandomizationsByMonth()

@checkRandomizationOption = (element) ->
  $(element).prop('checked', true)
  $(element).closest('.sheet-container').find('.radio').removeClass('selected')
  $(element).closest('.radio').addClass('selected')

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
