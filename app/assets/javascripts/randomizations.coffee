@visitURL = (event, url) ->
  if nonStandardClick(event)
    window.open(url)
  else
    Turbolinks.visit(url)

@loadRandomizationsByMonth = ->
  Highcharts.setOptions(
    lang:
      thousandsSep: ","
    colors: ["#7cb5ec", "#90ed7d", "#f7a35c", "#8085e9",
      "#f15c80", "#e4d354", "#2b908f", "#f45b5b", "#91e8e1"]
  )
  if $("[data-object~=draw-chart]").length > 0
    $.each($("[data-object~=draw-chart]"), ->
      $this = $(this)
      $(@).highcharts(
        credits:
          enabled: false
        chart:
          backgroundColor: null
          zoomType: "x"
          type: $(@).data("chart-type")
          events:
            click: (e) ->
              if $this.data("category-urls")?
                return if $this.data("category-urls")[Math.round(e.xAxis[0].value)].count == 0
                url = $this.data("category-urls")[Math.round(e.xAxis[0].value)].url
                visitURL(e, url)
        title:
          text: $(@).data("title")
        subtitle:
          text: (if document.ontouchstart == undefined then "Click and drag in the plot area to zoom in" else "Pinch the chart to zoom in")
          style:
            color: "#999"
        xAxis:
          categories: $(@).data("categories")
          title:
            text: $(@).data("xaxis")
        yAxis:
          min: 0
          minTickInterval: 1
          title:
            text: $(@).data("yaxis")
        tooltip:
          shared: true
          crosshairs: true
        plotOptions:
          column:
            pointPadding: 0.2
            borderWidth: 0
            # stacking: "normal"
            events:
              click: (e) ->
                url = e.point.options.url
                if url? and this.options.y != 0
                  visitURL(e, url)
        series: $(@).data("series")
      )
    )

@randomizationsTypeahead = ->
  $("[data-object~=randomization_subject_search]").typeahead("destroy")
  $("[data-object~=randomization_subject_search]").each( ->
    $this = $(this)
    bloodhound = new Bloodhound(
      datumTokenizer: Bloodhound.tokenizers.obj.whitespace("value")
      queryTokenizer: Bloodhound.tokenizers.whitespace
      remote:
        url: "#{$this.data("typeahead-url")}?q=%QUERY" # url: "#{root_url}projects/#{$this.data("project-slug")}/schemes/#{$this.data("randomization-scheme-id")}/subject_search?q=%QUERY"
        wildcard: "%QUERY"
    )
    $this.typeahead({ hint: true },
      display: "value"
      source: bloodhound
      templates:
        suggestion: (item) -> return "<div><strong>#{item.subject_code}</strong> <span class=\"label label-#{item.status_class}\">#{item.status}</span></div>"
    )
  )

@randomizationsReady = ->
  randomizationsTypeahead()
  loadRandomizationsByMonth()

@checkRandomizationOption = (element) ->
  $(element).prop("checked", true)

@selectRandomizationDropdown = (element, value) ->
  $(element).val(value)

@randomizationTermSelected = (element, event, datum) ->
  selectRandomizationDropdown("#stratification_factors_#{$(element).data("sfo-id")}", datum["site_id"])
  checkRandomizationOption("#stratification_factors_#{$(element).data("sfo-id")}_#{datum["site_id"]}")
  $.each(datum["stratification_factors"], (key, value) ->
    optionIdInSelect = $("[data-object~=option-value-lookup][data-factor-id=#{key}][data-option-value=#{value}]").data("option-id")
    selectRandomizationDropdown("#stratification_factors_#{key}", optionIdInSelect)
    radio_input = "[data-stratification-factor-id=#{key}][data-value=#{value}]"
    checkRandomizationOption(radio_input)
  )

$(document)
  .on("typeahead:selected", "[data-object~=randomization_subject_search]", (event, datum) ->
    randomizationTermSelected(@, event, datum)
  )
  .on("typeahead:autocompleted", "[data-object~=randomization_subject_search]", (event, datum) ->
    randomizationTermSelected(@, event, datum)
  )
